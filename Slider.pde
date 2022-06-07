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

// Klasse für einen Schieberegler
class Slider
{
    //
    // Variablen
    // 
  
    private int x = 0,   // x-Koordinate
                y = 0,   // y-Koordinate
                w = 200, // Breite
                h = 20;  // Höhe
                
    private float lo,  // Minimum
                   hi,  // Maximum
                   val; // Wert
                 
    private String name; // Name
     
    //
    // Konstruktor
    //
     
    public Slider(float lo, float hi, float val, String name)
    {
        this.lo = lo;
        this.hi = hi;
        this.val = val;
        this.name = name;
    }
    
    //
    // Basisfunktionen
    //
     
    // Wird von mouseDragged() aufgerufen
    // Gibt zurück, ob ein gewisses Mausevent auf den Schieberegler
    // zutrifft oder nicht.
    // Wenn das Event zutrifft, setze einen neuen Wert.
    public boolean mouse_event()
    {         
        // Überprüft, ob die Maus auf dem Regler liegt.
        if(!this.cursor_above())
            return false; // Wenn nicht, beende die Funktion negativ.
         
        float percentage = map(mouseX, this.x, this.x + this.w, 0, 100);
        this.val = percentage < 1 ? this.lo : percentage > 99 ? this.hi // für sehr klein / große Prozentwerte, setze `val` direkt auf `lo` bzw. `hi`, 
            : map(mouseX, this.x, this.x + this.w, lo, hi);       // berechne sonst einen genauen Wert.
            
        return true;
    }
    
    // Funktion um zu überprüfen, dass die Maus über dem Regler liegt
    public boolean cursor_above()
    {
        return mouseX > this.x && mouseX < this.x + this.w &&
               mouseY > this.y && mouseY < this.y + this.h;
    }
     
    // Zeichnet den Schieberegler
    public void render()
    {
        // Hintergrund (dunkelgrau, leicht transparent, Rechteck mit runden Ecken)
        fill(50, 150);
        noStroke();
        rect(this.x, this.y, this.w, this.h, this.w / 2);
         
        // "Griff" des Schiebereglers
        fill(255);
        circle(
            map(val, this.lo, this.hi, this.x, this.x + this.w), 
            this.y + this.h / 2, this.h
        ); 
         
        // Drucke den Text (Beschreibung + Wert) darunter
        textAlign(CENTER);
        text(String.format("%s: %.1f", this.name, this.val), this.x + this.w / 2, this.y + this.h * 1.75);
        textAlign(LEFT);
    }
     
    //
    // Getter
    //
     
    // gibt den Wert zurück
    public float get_value()
    {
        return this.val;
    }
    
    //
    // Setter
    //
    
    public Slider set_pos(int x, int y)
    {
        this.x = x;
        this.y = y;
        return this;
    }
}
