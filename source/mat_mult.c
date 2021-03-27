struct mat3 {
    int m00; int m01; int m02;
    int m10; int m11; int m12;
    int m20; int m21; int m22;
};

void __agbabi_mat3_mult( const struct mat3 * restrict srcA, const struct mat3 * restrict srcB, struct mat3 * restrict dst ) __attribute__((section(".iwram"))) __attribute__((target("arm")));
void __agbabi_mat3_mult_q( const struct mat3 * restrict srcA, const struct mat3 * restrict srcB, struct mat3 * restrict dst, int q ) __attribute__((section(".iwram"))) __attribute__((target("arm")));

void __agbabi_mat3_mult( const struct mat3 * restrict srcA, const struct mat3 * restrict srcB, struct mat3 * restrict dst ) {
    dst->m00 = ( srcA->m00 * srcB->m00 ) + ( srcA->m10 * srcB->m01 ) + ( srcA->m20 * srcB->m02 );
    dst->m01 = ( srcA->m01 * srcB->m00 ) + ( srcA->m11 * srcB->m01 ) + ( srcA->m21 * srcB->m02 );
    dst->m02 = ( srcA->m02 * srcB->m00 ) + ( srcA->m12 * srcB->m01 ) + ( srcA->m22 * srcB->m02 );

    dst->m10 = ( srcA->m00 * srcB->m10 ) + ( srcA->m10 * srcB->m11 ) + ( srcA->m20 * srcB->m12 );
    dst->m11 = ( srcA->m01 * srcB->m10 ) + ( srcA->m11 * srcB->m11 ) + ( srcA->m21 * srcB->m12 );
    dst->m12 = ( srcA->m02 * srcB->m10 ) + ( srcA->m12 * srcB->m11 ) + ( srcA->m22 * srcB->m12 );

    dst->m20 = ( srcA->m00 * srcB->m20 ) + ( srcA->m10 * srcB->m21 ) + ( srcA->m20 * srcB->m22 );
    dst->m21 = ( srcA->m01 * srcB->m20 ) + ( srcA->m11 * srcB->m21 ) + ( srcA->m21 * srcB->m22 );
    dst->m22 = ( srcA->m02 * srcB->m20 ) + ( srcA->m12 * srcB->m21 ) + ( srcA->m22 * srcB->m22 );
}

void __agbabi_mat3_mult_q( const struct mat3 * restrict srcA, const struct mat3 * restrict srcB, struct mat3 * restrict dst, int q ) {
    __agbabi_mat3_mult( srcA, srcB, dst );
    dst->m00 >>= q;
    dst->m01 >>= q;
    dst->m02 >>= q;

    dst->m10 >>= q;
    dst->m11 >>= q;
    dst->m12 >>= q;

    dst->m20 >>= q;
    dst->m21 >>= q;
    dst->m22 >>= q;
}

struct mat4 {
    int m00; int m01; int m02; int m03;
    int m10; int m11; int m12; int m13;
    int m20; int m21; int m22; int m23;
    int m30; int m31; int m32; int m33;
};

void __agbabi_mat4_mult( const struct mat4 * restrict srcA, const struct mat4 * restrict srcB, struct mat4 * restrict dst ) __attribute__((section(".iwram"))) __attribute__((target("arm")));
void __agbabi_mat4_mult_q( const struct mat4 * restrict srcA, const struct mat4 * restrict srcB, struct mat4 * restrict dst, int q ) __attribute__((section(".iwram"))) __attribute__((target("arm")));

void __agbabi_mat4_mult( const struct mat4 * restrict srcA, const struct mat4 * restrict srcB, struct mat4 * restrict dst ) {
    dst->m00 = ( srcA->m00 * srcB->m00 ) + ( srcA->m10 * srcB->m01 ) + ( srcA->m20 * srcB->m02 ) + ( srcA->m30 * srcB->m03 );
    dst->m01 = ( srcA->m01 * srcB->m00 ) + ( srcA->m11 * srcB->m01 ) + ( srcA->m21 * srcB->m02 ) + ( srcA->m31 * srcB->m03 );
    dst->m02 = ( srcA->m02 * srcB->m00 ) + ( srcA->m12 * srcB->m01 ) + ( srcA->m22 * srcB->m02 ) + ( srcA->m32 * srcB->m03 );
    dst->m03 = ( srcA->m03 * srcB->m00 ) + ( srcA->m13 * srcB->m01 ) + ( srcA->m23 * srcB->m02 ) + ( srcA->m33 * srcB->m03 );

    dst->m10 = ( srcA->m00 * srcB->m10 ) + ( srcA->m10 * srcB->m11 ) + ( srcA->m20 * srcB->m12 ) + ( srcA->m30 * srcB->m13 );
    dst->m11 = ( srcA->m01 * srcB->m10 ) + ( srcA->m11 * srcB->m11 ) + ( srcA->m21 * srcB->m12 ) + ( srcA->m31 * srcB->m13 );
    dst->m12 = ( srcA->m02 * srcB->m10 ) + ( srcA->m12 * srcB->m11 ) + ( srcA->m22 * srcB->m12 ) + ( srcA->m32 * srcB->m13 );
    dst->m13 = ( srcA->m03 * srcB->m10 ) + ( srcA->m13 * srcB->m11 ) + ( srcA->m23 * srcB->m12 ) + ( srcA->m33 * srcB->m13 );

    dst->m20 = ( srcA->m00 * srcB->m20 ) + ( srcA->m10 * srcB->m21 ) + ( srcA->m20 * srcB->m22 ) + ( srcA->m30 * srcB->m23 );
    dst->m21 = ( srcA->m01 * srcB->m20 ) + ( srcA->m11 * srcB->m21 ) + ( srcA->m21 * srcB->m22 ) + ( srcA->m31 * srcB->m23 );
    dst->m22 = ( srcA->m02 * srcB->m20 ) + ( srcA->m12 * srcB->m21 ) + ( srcA->m22 * srcB->m22 ) + ( srcA->m32 * srcB->m23 );
    dst->m23 = ( srcA->m03 * srcB->m20 ) + ( srcA->m13 * srcB->m21 ) + ( srcA->m23 * srcB->m22 ) + ( srcA->m33 * srcB->m23 );

    dst->m30 = ( srcA->m00 * srcB->m30 ) + ( srcA->m10 * srcB->m31 ) + ( srcA->m20 * srcB->m32 ) + ( srcA->m30 * srcB->m33 );
    dst->m31 = ( srcA->m01 * srcB->m30 ) + ( srcA->m11 * srcB->m31 ) + ( srcA->m21 * srcB->m32 ) + ( srcA->m31 * srcB->m33 );
    dst->m32 = ( srcA->m02 * srcB->m30 ) + ( srcA->m12 * srcB->m31 ) + ( srcA->m22 * srcB->m32 ) + ( srcA->m32 * srcB->m33 );
    dst->m33 = ( srcA->m03 * srcB->m30 ) + ( srcA->m13 * srcB->m31 ) + ( srcA->m23 * srcB->m32 ) + ( srcA->m33 * srcB->m33 );
}

void __agbabi_mat4_mult_q( const struct mat4 * restrict srcA, const struct mat4 * restrict srcB, struct mat4 * restrict dst, int q ) {
    __agbabi_mat4_mult( srcA, srcB, dst );

    dst->m00 >>= q;
    dst->m01 >>= q;
    dst->m02 >>= q;
    dst->m03 >>= q;

    dst->m10 >>= q;
    dst->m11 >>= q;
    dst->m12 >>= q;
    dst->m13 >>= q;

    dst->m20 >>= q;
    dst->m21 >>= q;
    dst->m22 >>= q;
    dst->m23 >>= q;

    dst->m30 >>= q;
    dst->m31 >>= q;
    dst->m32 >>= q;
    dst->m33 >>= q;
}
