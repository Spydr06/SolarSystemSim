/*
The MIT License (MIT)

Copyright (c) 2022 Spydr06

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

// Klasse, die eine 3x3 Matrix darstellt
class Matrix
{
    //
    // Variablen
    //

    // Matrix-Werte
    // 3x3 Layout:
    // m[0], m[1], m[2],
    // m[3], m[4], m[5],
    // m[6], m[7], m[8]
    public float[] m = new float[9];

    //
    // Basisfunktionen
    //

    // Konstruktor
    public Matrix() {}

    public Matrix(float[] m)
    {
        this.m = m;
    }

    // Vektormultiplikation:
    // x   m[0], m[1], m[2],   m[0] * x + m[1] * y + m[2] * z
    // y * m[3], m[4], m[5], = m[3] * x + m[4] * y + m[5] * z
    // z   m[6], m[7], m[8]    m[6] * x + m[7] * y + m[8] * z
    public PVector mult(PVector v)
    {
        return new PVector(
            m[0] * v.x + m[1] * v.y + m[2] * v.z,
            m[3] * v.x + m[4] * v.y + m[5] * v.z,
            m[6] * v.x + m[7] * v.y + m[8] * v.z
        );
    }

    // Matrixmultiplikation (3x3 * 3x3):
    // Bei der Multiplikation zweier Matrizen wird zu jeder Reihe der ersten Matrix
    // jede Spalte der zweiten Matrix multipliziert, und dann zusammenaddiert.
    public Matrix mult(Matrix b)
    {
        this.m = new float[] {
            m[0] * b.m[0] + m[1] * b.m[3] + m[2] * b.m[6],
            m[0] * b.m[1] + m[1] * b.m[4] + m[2] * b.m[7],
            m[0] * b.m[2] + m[1] * b.m[5] + m[2] * b.m[8],

            m[3] * b.m[0] + m[4] * b.m[3] + m[5] * b.m[6],
            m[3] * b.m[1] + m[4] * b.m[4] + m[5] * b.m[7],
            m[3] * b.m[2] + m[4] * b.m[5] + m[5] * b.m[8],

            m[6] * b.m[0] + m[7] * b.m[3] + m[8] * b.m[6],
            m[6] * b.m[1] + m[7] * b.m[4] + m[8] * b.m[7],
            m[6] * b.m[2] + m[7] * b.m[5] + m[8] * b.m[8],
        };
        return this;
    }

    //
    // Setter
    // Setter geben die Instanz der Klasse zur??ck, damit Setter-Funktionen aneinander gereiht werden k??nnen
    //

    // Setzt die Werte der Matrix auf ein neues Array
    public Matrix set_indices(float[] m)
    {
        this.m = m;
        return this;
    }

    //
    // Getter
    //

    // Kopiert eine Matrix, sodass keine Referenz mehr besteht
    public Matrix copy()
    {
        float[] m = Arrays.copyOf(this.m, this.m.length);
        return new Matrix(m);
    }
}
