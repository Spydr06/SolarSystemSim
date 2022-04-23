// Klasse für einen Schieberegler
class Slider
{
    //
    // Variablen
    // 
  
    private int x,   // x-Koordinate
                y,   // y-Koordinate
                w = 200, // Breite
                h = 20,  // Höhe
                lo,  // Minimum
                hi,  // Maximum
                val; // Wert
                 
    private String name; // Name
     
    //
    // Konstruktor
    //
     
    public Slider(int x, int y, int lo, int hi, int val, String name)
    {
        this.x = x;
        this.y = y;
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
        // Überprüft, ob die Maus auf dem Slider liegt
        if(mouseX > this.x && mouseX < this.x + this.w &&
           mouseY > this.y && mouseY < this.y + this.h)
        {
            val = (int) map(mouseX, this.x, this.x + this.w, lo, hi); // neuen Wert setzen (von `lo` bis `hi`)
            return true;
        }
         
        return false;
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
        text(String.format("%s: %d%%", this.name, (int) map(this.val, this.lo, this.hi, 0, 100)), this.x + this.w / 2, this.y + this.h * 1.75);
        textAlign(LEFT);
    }
     
    //
    // Getter
    //
     
    // gibt den Wert zurück
    public int get_value()
    {
        return this.val;
    }
}
