import numpy as np, itertools, sys

def hex2rgb(h):
    h = h.lstrip('#'); return np.array([int(h[i:i+2],16)/255 for i in (0,2,4)])

def srgb2lin(c): return np.where(c <= 0.04045, c/12.92, ((c+0.055)/1.055)**2.4)
def lin2srgb(c):
    c = np.clip(c,0,1)
    return np.where(c <= 0.0031308, c*12.92, 1.055*c**(1/2.4)-0.055)

M = np.array([[0.4124564,0.3575761,0.1804375],
              [0.2126729,0.7151522,0.0721750],
              [0.0193339,0.1191920,0.9503041]])
WP = np.array([0.95047,1.0,1.08883])

def rgb2lab(rgb):
    xyz = M @ srgb2lin(rgb) / WP
    f = np.where(xyz > (6/29)**3, np.cbrt(xyz), xyz/(3*(6/29)**2) + 4/29)
    return np.array([116*f[1]-16, 500*(f[0]-f[1]), 200*(f[1]-f[2])])

def ciede2000(l1, l2):
    L1,a1,b1 = l1; L2,a2,b2 = l2
    C1,C2 = np.hypot(a1,b1), np.hypot(a2,b2); Cb=(C1+C2)/2
    G = 0.5*(1-np.sqrt(Cb**7/(Cb**7+25**7))) if Cb>0 else 0
    a1p,a2p = (1+G)*a1,(1+G)*a2
    C1p,C2p = np.hypot(a1p,b1), np.hypot(a2p,b2)
    h1p = np.degrees(np.arctan2(b1,a1p))%360; h2p = np.degrees(np.arctan2(b2,a2p))%360
    dLp = L2-L1; dCp = C2p-C1p
    if C1p*C2p == 0: dhp = 0
    elif abs(h2p-h1p) <= 180: dhp = h2p-h1p
    elif h2p-h1p > 180: dhp = h2p-h1p-360
    else: dhp = h2p-h1p+360
    dHp = 2*np.sqrt(C1p*C2p)*np.sin(np.radians(dhp)/2)
    Lbp=(L1+L2)/2; Cbp=(C1p+C2p)/2
    if C1p*C2p == 0: hbp = h1p+h2p
    elif abs(h1p-h2p) <= 180: hbp=(h1p+h2p)/2
    elif h1p+h2p < 360: hbp=(h1p+h2p+360)/2
    else: hbp=(h1p+h2p-360)/2
    T = (1-0.17*np.cos(np.radians(hbp-30))+0.24*np.cos(np.radians(2*hbp))
         +0.32*np.cos(np.radians(3*hbp+6))-0.20*np.cos(np.radians(4*hbp-63)))
    dTh = 30*np.exp(-((hbp-275)/25)**2)
    Rc = 2*np.sqrt(Cbp**7/(Cbp**7+25**7)) if Cbp>0 else 0
    Sl = 1+(0.015*(Lbp-50)**2)/np.sqrt(20+(Lbp-50)**2); Sc = 1+0.045*Cbp; Sh = 1+0.015*Cbp*T
    Rt = -np.sin(np.radians(2*dTh))*Rc
    return np.sqrt((dLp/Sl)**2+(dCp/Sc)**2+(dHp/Sh)**2+Rt*(dCp/Sc)*(dHp/Sh))

CVD = {
 'protan': np.array([[0.152286,1.052583,-0.204868],[0.114503,0.786281,0.099216],[-0.003882,-0.048116,1.051998]]),
 'deutan': np.array([[0.367322,0.860646,-0.227968],[0.280085,0.672501,0.047413],[-0.011820,0.042940,0.968881]]),
 'tritan': np.array([[1.255528,-0.076749,-0.178779],[-0.078411,0.930809,0.147602],[0.004733,0.691367,0.303900]]),
}
def simulate(rgb, kind): return lin2srgb(CVD[kind] @ srgb2lin(rgb))

def contrast(fg, bg=np.array([1.,1.,1.])):
    def lum(c):
        lc = srgb2lin(c); return 0.2126*lc[0]+0.7152*lc[1]+0.0722*lc[2]
    a,b = lum(fg), lum(bg)
    hi,lo = max(a,b), min(a,b); return (hi+0.05)/(lo+0.05)

def report(name, pal):
    rgbs = [hex2rgb(h) for h in pal]
    labs = [rgb2lab(r) for r in rgbs]
    Ls = [round(l[0],1) for l in labs]
    order = np.argsort(Ls)
    gaps = [round(Ls[order[i+1]]-Ls[order[i]],1) for i in range(len(order)-1)]
    print(f"\n=== {name} ===")
    print("hex :", pal)
    print("L*  :", Ls, " sorted-gaps:", gaps, " min gap:", min(gaps))
    print("contrast vs white:", [round(contrast(r),2) for r in rgbs])
    worst_overall = 99
    for cond in ['normal','protan','deutan','tritan']:
        sim = rgbs if cond=='normal' else [simulate(r,cond) for r in rgbs]
        sl = [rgb2lab(s) for s in sim]
        d = [(round(ciede2000(sl[i],sl[j]),1), pal[i], pal[j]) for i,j in itertools.combinations(range(len(pal)),2)]
        worst = min(d)
        worst_overall = min(worst_overall, worst[0])
        print(f"  {cond:7s} min dE00 = {worst[0]:5.1f}  ({worst[1]} vs {worst[2]})")
    print(f"  WORST across all conditions: {worst_overall}")
    return min(gaps), worst_overall

if __name__ == '__main__':
    # The book's discrete series palette. Change it here, re-run with
    #   python3 scripts/check_palette.py
    # and keep the numbers in R/nus_theme.R's header comment in step.
    report('NUS discrete series', ['#003D7C', '#96233F', '#007E96', '#E8720C', '#BFC6CE'])
