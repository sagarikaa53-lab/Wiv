v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 1710 -1060 1750 -1060 {lab=in}
N 1710 -1160 1710 -1060 {lab=in}
N 1710 -1160 1750 -1160 {lab=in}
N 1680 -1110 1710 -1110 {lab=in}
N 1790 -1130 1790 -1090 {lab=out}
N 1790 -1240 1790 -1190 {lab=vdd}
N 1790 -1240 1810 -1240 {lab=vdd}
N 1790 -1030 1790 -970 {lab=vss}
N 1790 -970 1830 -970 {lab=vss}
N 1790 -1110 1880 -1110 {lab=out}
N 1790 -1060 1820 -1060 {lab=vss}
N 1820 -1060 1820 -970 {lab=vss}
C {sky130_fd_pr/nfet_01v8.sym} 1770 -1060 0 0 {name=M1
W=4.5
L=0.18
nf=3 
mult=1
ad="expr('int((@nf + 1)/2) * @W / @nf * 0.29')"
pd="expr('2*int((@nf + 1)/2) * (@W / @nf + 0.29)')"
as="expr('int((@nf + 2)/2) * @W / @nf * 0.29')"
ps="expr('2*int((@nf + 2)/2) * (@W / @nf + 0.29)')"
nrd="expr('0.29 / @W ')" nrs="expr('0.29 / @W ')"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {ipin.sym} 1680 -1110 0 0 {name=p1 lab=in}
C {iopin.sym} 1830 -970 0 0 {name=p2 lab=vss}
C {opin.sym} 1880 -1110 0 0 {name=p3 lab=out}
C {sky130_fd_pr/pfet3_01v8.sym} 1770 -1160 0 0 {name=M2
W=3
L=0.18
body=vdd
nf=3
mult=1
ad="expr('int((@nf + 1)/2) * @W / @nf * 0.29')"
pd="expr('2*int((@nf + 1)/2) * (@W / @nf + 0.29)')"
as="expr('int((@nf + 2)/2) * @W / @nf * 0.29')"
ps="expr('2*int((@nf + 2)/2) * (@W / @nf + 0.29)')"
nrd="expr('0.29 / @W ')" nrs="expr('0.29 / @W ')"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {iopin.sym} 1810 -1240 0 0 {name=p4 lab=vdd
}
