// Klasse für einen Slider
class Slider
{
     private int x,   // x-Koordinate
                 y,   // y-Koordinate
                 w,   // Breite
                 h,   // Höhe
                 lo,  // Minimum
                 hi,  // Maximum
                 val; // Wert
                 
     private String name; // Name
     
     // Konstruktor
     public Slider(int x, int y, int lo, int hi, int val, String name)
     {
         this.x = x;
         this.y = y;
         this.lo = lo;
         this.hi = hi;
         this.w = 200;
         this.h = 20;
         this.val = val;
         this.name = name;
     }
     
     public boolean mouse_event()
     {         
         if(mouseX > this.x && mouseX < this.x + this.w &&
             mouseY > this.y && mouseY < this.y + this.h)
         {
             val = (int) map(mouseX, this.x, this.x + this.w, lo, hi);
           
             return true;
         }
         
         return false;
     }
     
     public void render()
     {
         fill(50);
         noStroke();
         rect(this.x, this.y, this.w, this.h, this.w / 2);
         fill(220);
         circle(
             map(val, this.lo, this.hi, this.x, this.x + this.w), 
             this.y + this.h / 2, this.h
         ); 
         
         textAlign(CENTER);
         text(String.format("%s: %d", this.name, this.val), this.x + this.w / 2, this.y + this.h * 1.75);
         textAlign(LEFT);
     }
     
     public int get_value()
     {
         return this.val;
     }
}