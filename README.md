cpu
===

「マイクロプロセッサの設計と実装」のソースコード

本来main_memory.vはQuartusIIで生成するが、ここではFPGAボードがなくてもシミュレーションできるようにしている。
main_memory.vに書かれたプログラムは命令の動作を確認するためのプログラムで、全体で意味のあるコードではない。

コンパイル方法
$ iverilog *.v

実行方法
$ ./a.out

シミュレーション方法
$ gtkwave test_bench.vcd
