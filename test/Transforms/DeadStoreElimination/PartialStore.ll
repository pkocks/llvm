; RUN: opt < %s -basicaa -dse -S | FileCheck %s
target datalayout = "E-p:64:64:64-a0:0:8-f32:32:32-f64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-v64:64:64-v128:128:128"

; Ensure that the dead store is deleted in this case.  It is wholely
; overwritten by the second store.
define void @test1(i32 *%V) {
        %V2 = bitcast i32* %V to i8*            ; <i8*> [#uses=1]
        store i8 0, i8* %V2
        store i32 1234567, i32* %V
        ret void
; CHECK: @test1
; CHECK-NEXT: store i32 1234567
}

; Note that we could do better by merging the two stores into one.
define void @test2(i32* %P) {
; CHECK: @test2
  store i32 0, i32* %P
; CHECK: store i32
  %Q = bitcast i32* %P to i16*
  store i16 1, i16* %Q
; CHECK: store i16
  ret void
}


define i32 @test3(double %__x) {
; CHECK: @test3
; CHECK: store double
  %__u = alloca { [3 x i32] }
  %tmp.1 = bitcast { [3 x i32] }* %__u to double*
  store double %__x, double* %tmp.1
  %tmp.4 = getelementptr { [3 x i32] }* %__u, i32 0, i32 0, i32 1
  %tmp.5 = load i32* %tmp.4
  %tmp.6 = icmp slt i32 %tmp.5, 0
  %tmp.7 = zext i1 %tmp.6 to i32
  ret i32 %tmp.7
}
