v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 1530 -1100 1530 -1090 {lab=in}
N 1530 -1100 1630 -1100 {lab=in}
N 1930 -1140 1930 -1100 {lab=#net1}
N 1460 -1140 1930 -1140 {lab=#net1}
N 1460 -1140 1460 -1090 {lab=#net1}
N 1460 -1030 1530 -1030 {lab=0}
N 1530 -1030 1930 -1030 {lab=0}
N 1930 -1060 1930 -1030 {lab=0}
N 1620 -1030 1620 -1020 {lab=0}
N 1530 -1120 1540 -1120 {lab=in}
N 1530 -1120 1530 -1100 {lab=in}
N 1930 -1080 1980 -1080 {lab=out}
C {inverterr.sym} 1780 -1080 0 0 {name=x1}
C {vsource.sym} 1530 -1060 0 0 {name=V1 value="PWL(0 0 20n 0 900n 1.8)" savecurrent=false}
C {vsource.sym} 1460 -1060 0 0 {name=V2 value=1.8 savecurrent=false}
C {gnd.sym} 1620 -1020 0 0 {name=l1 lab=0}
C {opin.sym} 1540 -1120 0 0 {name=p1 lab=in}
C {opin.sym} 1980 -1080 0 0 {name=p2 lab=out
}
C {code_shown.sym} 1710 -1190 0 0 {name=s1 only_toplevel=false value=".lib/usr/share/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt"}
C {code_shown.sym} 1730 -980 0 0 {name=s2 only_toplevel=false value=".control
tran 1n 1u
plot V(in) V(out)
.endc"}
