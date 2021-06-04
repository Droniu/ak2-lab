#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <iostream>

struct vector {
    float f1, f2, f3, f4;
};

// działania SIMD

clock_t addSIMD(struct vector vec1, struct vector vec2) {
    clock_t start, end;
    struct vector result;
    start = clock();
    /* do dzialan SIMD korzystamy z rejestrow XMM */
    asm(
        "movups %[v1], %%xmm0 \n"            //ladowanie v1 do rejestru xmm0
        "movups %[v2], %%xmm1 \n"            //ladowanie v2 do rejestru xmm1
        "addps %%xmm0, %%xmm1 \n"            //dodawanie wektorow w rejestrze xmm0 i xmm1
        "movups %%xmm1, %[vresult] \n"       //ladowanie wyniku z xmm1 do wektora vresult (w pamieci)
        : [ vresult ] "=m"(result) 
        : [ v1 ] "m"(vec1), [ v2 ] "m"(vec2)
    );
    end = clock();
    return (end - start); // zwrot roznicy w cyklach procesora po wykonaniu wstawki z asm
}
clock_t subSIMD(struct vector vec1, struct vector vec2)
{
    clock_t start, end;
    struct vector result;
    start = clock();
    asm(
        "movups %[v1], %%xmm0\n"
        "movups %[v2], %%xmm1\n"
        "subps %%xmm0, %%xmm1\n"
        "movups %%xmm1, %[vresult]\n"
        : [ vresult ] "=m"(result)
        : [ v1 ] "m"(vec1), [ v2 ] "m"(vec2));
    end = clock();
    return end - start;
}

clock_t mulSIMD(struct vector vec1, struct vector vec2)
{
    clock_t start, end;
    struct vector result;
    start = clock();
    asm(
        "movups %[v1], %%xmm0\n"
        "movups %[v2], %%xmm1\n"
        "mulps %%xmm0, %%xmm1\n"
        "movups %%xmm1, %[vresult]\n"
        : [ vresult ] "=m"(result)
        : [ v1 ] "m"(vec1), [ v2 ] "m"(vec2));
    end = clock();
    return end - start;
}

clock_t divSIMD(struct vector vec1, struct vector vec2)
{
    clock_t start, end;
    struct vector result;
    start = clock();
    asm(
        "movups %[v1], %%xmm0\n"
        "movups %[v2], %%xmm1\n"
        "divps %%xmm0, %%xmm1\n"
        "movups %%xmm1, %[vresult]\n"
        : [ vresult ] "=m"(result)
        : [ v1 ] "m"(vec1), [ v2 ] "m"(vec2));
    end = clock();
    return end - start;
}

// generator liczb pseudolosowych z danego zakresu

float randFloat(float min, float max) {
    float scale = rand() / (float) RAND_MAX; /* [0, 1.0] */
    return min + scale * ( max - min );      /* [min, max] */
}

// funkcja wypelniajaca tabele wektorow

void generateNumbers(int arrSize, struct vector *arr1, struct vector *arr2) {
    srand(time(0)); // ustawienie seed (ziarna) 

    for (int i = 0; i < arrSize; i++) {
        // wypelnianie czterech liczb kazdego wektora tablicy 1
        arr1[i].f1 = randFloat(-1.0, 1.0);
        arr1[i].f2 = randFloat(-1.0, 1.0);
        arr1[i].f3 = randFloat(-1.0, 1.0);
        arr1[i].f4 = randFloat(-1.0, 1.0);
        // analogicznie dla tablicy 2
        arr2[i].f1 = randFloat(-1.0, 1.0);
        arr2[i].f2 = randFloat(-1.0, 1.0);
        arr2[i].f3 = randFloat(-1.0, 1.0);
        arr2[i].f4 = randFloat(-1.0, 1.0);
    }
}

// funkcja zwracająca czasy SIMD

double* SIMD(int trials, int arrSize, struct vector *arr1, struct vector *arr2) {

    double add = 0.0;
    double sub = 0.0;
    double mul = 0.0;
    double div = 0.0;

    for (int i = 0; i < trials; i++) {
        for (int j = 0; j < arrSize; j++) {
            add += addSIMD(arr1[i], arr2[j]);
            sub += subSIMD(arr1[i], arr2[j]);
            mul += mulSIMD(arr1[i], arr2[j]);
            div += divSIMD(arr1[i], arr2[j]);

        }
    }

    // obliczanie faktycznych czasow w zaleznosci od procesora

    add /= (trials * CLOCKS_PER_SEC);
    sub /= (trials * CLOCKS_PER_SEC);
    mul /= (trials * CLOCKS_PER_SEC);
    div /= (trials * CLOCKS_PER_SEC);


    double *ptr = new double[4];
    ptr[0] = add;
    ptr[1] = sub;
    ptr[2] = mul;
    ptr[3] = div;

    return ptr;

}

//double* SISD(int trials, int arrSize, struct )

int main() {
    
    const int ARR_SIZE = 8192;
    const int TRIALS = 10;

    struct vector vArray1[ARR_SIZE];
    struct vector vArray2[ARR_SIZE];

    generateNumbers(ARR_SIZE, vArray1, vArray2);

    FILE *simdResults = fopen("simd.txt", "w");
    FILE *sisdResults = fopen("sisd.txt", "w");

    double* resultM = SIMD(TRIALS, ARR_SIZE, vArray1, vArray2);
    fprintf(
        simdResults, 
        "Typ obliczen: SIMD\nLiczb liczb: %i\nSredni czas [s]:\n+ %f\n- %f\n* %f\n/ %f\n",
        ARR_SIZE,
        resultM[0], 
        resultM[1], 
        resultM[2], 
        resultM[3]
    );
    

    return 0;
}