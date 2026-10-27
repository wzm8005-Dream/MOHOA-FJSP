"""Rebuild tables/plots from the supplied archive. No optimizer is called.

Run this file in a Python IDE, or use --no-plots for numeric analysis only.
Use --verify-fronts to recompute every IGD/HV from the exported objective
matrices and exact saved reference sets, checking the archived per-run CSV.
Generated output is separate from data/ and may be deleted safely.
"""
from pathlib import Path
from collections import defaultdict
import argparse,csv,json,math
import numpy as np
from scipy.io import loadmat
from scipy.spatial import cKDTree
from scipy.stats import rankdata,friedmanchisquare

ROOT=Path(__file__).resolve().parents[1]
MAIN=['MOHOA','MOPSO','NSGA3','MODA','MOGOA','MOMA','MOEAD']
ABL=['MOHOA_NoGPS','MOHOA_NoCauchy','MOHOA_Crowding','MOHOA_Base']
FUN=['ZDT1','ZDT2','ZDT3','ZDT4','ZDT6']+[f'DTLZ{i}' for i in range(1,8)]
MK=[f'Mk{i:02d}' for i in range(1,11)]
LABELS={'NSGA3':'NSGA-III','MOEAD':'MOEA/D','HSGA_Paper':'HSGA',
        'MOHOA_NoGPS':'No GPS','MOHOA_NoCauchy':'No Cauchy','MOHOA_Crowding':'Crowding','MOHOA_Base':'Base'}

def read(path):
    with Path(path).open(encoding='utf-8-sig') as f:return list(csv.DictReader(f))

def write(out,name,rows):
    with (out/name).open('w',encoding='utf-8-sig',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)

def front(F):
    U=np.unique(F,axis=0);kept=[]
    for x in U:
        if kept and np.any(np.all(np.asarray(kept)<=x,axis=1)):continue
        kept.append(x)
    return np.asarray(kept)

def hv2(F,ref):
    F=F[np.lexsort((F[:,1],F[:,0]))]
    best=np.minimum.accumulate(F[:,1]);previous=np.r_[ref[1],best[:-1]]
    return float(np.sum((ref[0]-F[:,0])*np.maximum(0,previous-F[:,1])))

def hv(F,ref):
    F=F[np.all(F<ref,axis=1)]
    if not len(F):return 0.
    if F.shape[1]==2:return hv2(F,ref)
    x=np.unique(F[:,0]);v=0.
    for left,right in zip(x,np.r_[x[1:],ref[0]]):
        v+=(right-left)*hv2(F[F[:,0]<=left,1:],ref[1:])
    return float(v)

def coverage(A,B):
    return float(np.any(np.all(A[:,None,:]<=B[None,:,:],axis=2)&
                  np.any(A[:,None,:]<B[None,:,:],axis=2),axis=0).mean())

def ranksum(x,y):
    n=len(x);m=len(y);v=np.r_[x,y];U=rankdata(v)[:n].sum()-n*(n+1)/2
    _,ties=np.unique(v,return_counts=True);N=n+m
    variance=n*m/12*((N+1)-sum(ties**3-ties)/(N*(N-1)))
    p=1. if variance<=0 else math.erfc(max(0,abs(U-n*m/2)-.5)/math.sqrt(2*variance))
    return p,2*U/(n*m)-1

def analyze(out,verify):
    rows=read(ROOT/'data/per_run.csv');assert len(rows)==2520
    groups=defaultdict(list)
    for r in rows:
        for key in ['Repeat','Seed','Iterations']:r[key]=int(r[key])
        for key in ['IGD','HV','Seconds','SecondsPerIteration']:r[key]=float(r[key])
        groups[r['Problem'],r['Algorithm']].append(r)
    for g in groups.values():
        g.sort(key=lambda r:r['Repeat'])
        assert [r['Repeat'] for r in g]==list(range(1,11))
    cache={};refs={};coverage_rows=[];selected=[];verification=[]
    for p in FUN+MK:
        cache[p]=loadmat(ROOT/f'data/final_objectives/{p}.mat')
        z=loadmat(ROOT/f'data/reference_fronts/{p}.mat');lo=z['Lower'].ravel();span=z['Upper'].ravel()-lo
        span[span<=1e-12]=1;P=(z['R']-lo)/span;refs[p]=(P,lo,span)
        algorithms=MAIN+ABL+(['HSGA_Paper'] if p in MK else [])
        for a in algorithms:
            g=groups[p,a]
            for r in g:
                F=front(cache[p][f"F_{a}_r{r['Repeat']:02d}"])
                cache[p][f"ND_{a}_r{r['Repeat']:02d}"]=F
                if verify:
                    Y=(F-lo)/span;igd=float(cKDTree(Y).query(P,k=1)[0].mean());volume=hv(Y,np.ones(F.shape[1]))
                    assert np.isclose(igd,r['IGD'],rtol=1e-9,atol=1e-11),(p,a,r['Repeat'],'IGD',igd,r['IGD'])
                    assert np.isclose(volume,r['HV'],rtol=1e-9,atol=1e-11),(p,a,r['Repeat'],'HV',volume,r['HV'])
                    verification.append({'Problem':p,'Algorithm':a,'Repeat':r['Repeat'],'IGD':igd,'HV':volume})
            if a in MAIN+['HSGA_Paper']:
                mean=float(np.mean([r['HV'] for r in g]));r=min(g,key=lambda r:(abs(r['HV']-mean),r['Repeat']))
                selected.append({'Problem':p,'Algorithm':a,'Repeat':r['Repeat'],'Seed':r['Seed'],'MeanHV':mean,'SelectedHV':r['HV']})
        if p in MK:
            for a in MAIN[1:]+['HSGA_Paper']:
                fwd=[];rev=[]
                for repeat in range(1,11):
                    A=cache[p][f'ND_MOHOA_r{repeat:02d}'];B=cache[p][f'ND_{a}_r{repeat:02d}']
                    fwd.append(coverage(A,B));rev.append(coverage(B,A))
                coverage_rows.append({'Problem':p,'Comparator':a,'ForwardMean':np.mean(fwd),'ForwardStd':np.std(fwd,ddof=1),
                                      'ReverseMean':np.mean(rev),'ReverseStd':np.std(rev,ddof=1)})
        print(p,'saved data checked' if verify else 'saved data loaded',flush=True)
    summary=[];medians={}
    for (p,a),g in groups.items():
        for metric in ['IGD','HV','SecondsPerIteration']:
            v=np.array([r[metric] for r in g]);q=np.quantile(v,[.25,.5,.75]);medians[p,a,metric]=q[1]
            summary.append({'Problem':p,'Algorithm':a,'Metric':metric,'N':10,'Mean':float(v.mean()),'Std':float(v.std(ddof=1)),
                            'Median':float(q[1]),'Q1':float(q[0]),'Q3':float(q[2]),'IQR':float(q[2]-q[0])})
    tests=[]
    for suite,ps in [('ZDT',FUN[:5]),('DTLZ',FUN[5:]),('MK',MK)]:
        for category,others in [('main',MAIN[1:]+(['HSGA_Paper'] if suite=='MK' else [])),('ablation',ABL)]:
            for metric in ['IGD','HV']:
                family=[]
                for p in ps:
                    x=np.array([r[metric] for r in groups[p,'MOHOA']])
                    for a in others:
                        y=np.array([r[metric] for r in groups[p,a]]);pv,delta=ranksum(x,y)
                        better=delta*(-1 if metric=='IGD' else 1)
                        family.append({'Suite':suite,'Category':category,'Problem':p,'Comparator':a,'Metric':metric,
                          'RawP':pv,'RankEffect':delta,'Direction':'better' if better>0 else 'worse' if better<0 else 'equal'})
                ordered=sorted(family,key=lambda r:r['RawP']);prev=0
                for i,r in enumerate(ordered):
                    prev=max(prev,min(1,r['RawP']*(len(ordered)-i)));r['HolmP']=prev
                    r['Symbol']='=' if prev>=.05 else '+' if r['Direction']=='better' else '-'
                tests.extend(family)
    friedman=[]
    for suite,ps,algs in [('functions',FUN,MAIN),('MK',MK,MAIN+['HSGA_Paper'])]:
        for metric in ['IGD','HV']:
            matrix=np.array([[medians[p,a,metric] for a in algs] for p in ps]);q,pv=friedmanchisquare(*matrix.T)
            ranks=np.array([rankdata(v if metric=='IGD' else -v) for v in matrix]).mean(axis=0)
            for a,rank in zip(algs,ranks):friedman.append({'Suite':suite,'Metric':metric,'Algorithm':a,'MeanRank':rank,'Statistic':q,'P':pv})
    write(out,'summary.csv',summary);write(out,'pairwise_holm.csv',tests);write(out,'friedman.csv',friedman)
    write(out,'MK_C_metric.csv',coverage_rows);write(out,'representative_runs.csv',selected)
    if verify:write(out,'recomputed_per_run_indicators.csv',verification)
    # Confirm reconstructed numerical tables against the archived exact values.
    old={(r['Problem'],r['Algorithm'],r['Metric']):r for r in read(ROOT/'data/tables/all_summary.csv')}
    for r in summary:
        for k in ['Mean','Std','Median','IQR']:assert np.isclose(r[k],float(old[r['Problem'],r['Algorithm'],r['Metric']][k]),rtol=1e-12,atol=1e-14)
    oldc={(r['Problem'],r['Comparator']):r for r in read(ROOT/'data/tables/MK_C_metric.csv')}
    for r in coverage_rows:
        for k in ['ForwardMean','ForwardStd','ReverseMean','ReverseStd']:assert abs(r[k]-float(oldc[r['Problem'],r['Comparator']][k]))<1e-12
    for name,suite in [('functions_pairwise_holm.csv','functions'),('MK_pairwise_holm.csv','MK')]:
        for r in read(ROOT/'data/tables'/name):
            t=next(t for t in tests if t['Category']=='main' and t['Problem']==r['Problem'] and t['Comparator']==r['Comparator'] and t['Metric']==r['Metric'])
            assert abs(t['HolmP']-float(r['HolmP']))<1e-12
    (out/'verification.json').write_text(json.dumps({'Runs':2520,'SummaryAndCoverageMatchArchive':True,'MainHolmTestsMatchArchive':True,
       'AllIGD_HVRecomputed':verify,'OptimizationRunsExecuted':0},indent=2),encoding='utf8')
    return rows,summary,cache,refs,selected

def plots(out,rows,summary,cache,refs,selected):
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.patches import Patch
    plt.rcParams.update({'font.family':'serif','font.size':9,'pdf.fonttype':42})
    colors=['#C83737','#0072B2','#009E73','#CC79A7','#D98C00','#7851A9','#008C95','#666666']
    markers=['*','o','s','^','D','v','P','h'];figdir=out/'figures';figdir.mkdir(exist_ok=True)
    def save(fig,name):
        fig.savefig(figdir/(name+'.png'),dpi=300,bbox_inches='tight');fig.savefig(figdir/(name+'.pdf'),bbox_inches='tight');plt.close(fig)
    for p in ['ZDT2','ZDT3','ZDT4','DTLZ1','DTLZ2','DTLZ4','DTLZ6','DTLZ7']+MK:
        P,lo,span=refs[p];M=P.shape[1];algs=MAIN+(['HSGA_Paper'] if p in MK else [])
        fig=plt.figure(figsize=(10,4.1))
        for pane in [1,2]:
            ax=fig.add_subplot(1,2,pane,projection='3d' if M==3 else None)
            ax.scatter(*P.T,s=2,color='black',alpha=.4,label='Reference')
            for i,a in enumerate(algs):
                rep=next(r['Repeat'] for r in selected if r['Problem']==p and r['Algorithm']==a)
                Y=(cache[p][f'ND_{a}_r{rep:02d}']-lo)/span
                if pane==2:Y=Y[np.all((Y>=-.05)&(Y<=1.05),axis=1)]
                ax.scatter(*Y.T,s=18,marker=markers[i],color=colors[i],label=LABELS.get(a,a))
            ax.set_xlabel('Normalized f1');ax.set_ylabel('Normalized f2')
            if M==3:ax.set_zlabel('Normalized f3')
            if pane==2:
                ax.set_xlim(-.05,1.05);ax.set_ylim(-.05,1.05)
                if M==3:ax.set_zlim(-.05,1.05)
            ax.set_title(p+(' full range' if pane==1 else ' detail'));ax.grid(alpha=.2)
        handles,labels=ax.get_legend_handles_labels();fig.legend(handles,labels,loc='lower center',ncol=4,bbox_to_anchor=(.5,-.12));fig.subplots_adjust(wspace=.3)
        save(fig,p+'_fronts')
    lookup={(r['Problem'],r['Algorithm'],r['Metric']):r for r in summary}
    for suite,ps,algs in [('functions',FUN,MAIN),('MK',MK,MAIN+['HSGA_Paper'])]:
        fig,ax=plt.subplots(figsize=(10,4));x=np.arange(len(ps))
        for i,a in enumerate(algs):
            g=[lookup[p,a,'SecondsPerIteration'] for p in ps]
            ax.plot(x,[r['Median'] for r in g],marker=markers[i],color=colors[i],label=LABELS.get(a,a))
            ax.fill_between(x,[r['Q1'] for r in g],[r['Q3'] for r in g],color=colors[i],alpha=.1)
        ax.set_yscale('log');ax.set_xticks(x,ps,rotation=30);ax.set_ylabel('Seconds per iteration');ax.legend(ncol=4);ax.grid(alpha=.2)
        save(fig,suite+'_runtime')
        for metric in ['IGD','HV']:
            fig,ax=plt.subplots(figsize=(10,4))
            for i,a in enumerate(ABL):
                if metric=='IGD':v=[lookup[p,a,metric]['Median']/lookup[p,'MOHOA',metric]['Median'] for p in ps]
                else:v=[lookup[p,a,metric]['Mean']-lookup[p,'MOHOA',metric]['Mean'] for p in ps]
                ax.plot(x,v,marker=markers[i+1],label=LABELS[a])
            ax.axhline(1 if metric=='IGD' else 0,color='black',ls='--',lw=.8)
            ax.set_xticks(x,ps,rotation=30);ax.set_ylabel('Median IGD relative to MOHOA' if metric=='IGD' else 'Mean HV minus MOHOA')
            ax.legend(ncol=4);ax.grid(alpha=.2);save(fig,suite+'_ablation_'+metric)
    operations=read(ROOT/'data/tables/MK10_operations.csv');extremes=read(ROOT/'data/tables/MK10_extreme_objectives.csv')
    cmap=plt.get_cmap('tab20')
    for idx,e in enumerate(extremes,1):
        fig,ax=plt.subplots(figsize=(11,4.5));key=e['Criterion']
        for r in operations:
            if r['Criterion']!=key:continue
            ax.barh(int(r['Machine']),float(r['End'])-float(r['Start']),left=float(r['Start']),height=.7,
                    color=cmap((int(r['Job'])-1)%20),edgecolor='white',lw=.3)
        ax.axvline(float(e['Cmax']),color='black',ls='--',lw=.8);ax.set_yticks(range(1,16));ax.set_ylim(.5,15.5)
        ax.set_xlabel('Time (h)');ax.set_ylabel('Machine');ax.set_title('MK10 '+key)
        ax.legend(handles=[Patch(color=cmap(j),label=f'J{j+1}') for j in range(20)],loc='upper left',bbox_to_anchor=(1,1),ncol=2,fontsize=7)
        save(fig,'MK10_Gantt_'+str(idx))
    b=read(ROOT/'data/tables/MK_makespan_reference.csv');fig,ax=plt.subplots(figsize=(8,3.5));x=np.arange(len(b));w=.36
    ax.bar(x-w/2,[float(r['BestGapPercent']) for r in b],w,label='Best makespan gap')
    ax.bar(x+w/2,[float(r['MeanGapPercent']) for r in b],w,label='Mean makespan gap')
    ax.set_xticks(x,[r['Instance'] for r in b]);ax.set_ylabel('Excess over reference (%)');ax.legend();save(fig,'makespan_reference_gaps')

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--no-plots',action='store_true');parser.add_argument('--verify-fronts',action='store_true')
    args=parser.parse_args();out=ROOT/'generated';out.mkdir(exist_ok=True)
    result=analyze(out,args.verify_fronts)
    if not args.no_plots:plots(out,*result)
    print('Saved-data analysis complete:',out)
