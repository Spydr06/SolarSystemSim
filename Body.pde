// Klasse, die einen Körper darstellt
class Body 
{
    //
    // Variablen
    //

    private double mass; // die Masse des Körpers
    private PVector pos; // die Position des Körpers
    private PVector vel; // die Geschwindigkeit des Körpers
    private PVector acc; // die Beschleunigung des Körpers
    private String name = "";

    //
    // Konstruktor
    //

    public Body(double mass) 
    {
        this.mass = mass;
        this.pos = new PVector();
        this.vel = new PVector();
        this.acc = new PVector();
    }

    //
    // Basisfunktionen
    //

    // Funktion zum Aktualisieren der Parameter eines Körpers
    public void update(double delta)
    {
        this.vel.add(this.acc.get().mult((float) delta)); // Die Beschleunigung multipliziert mit der Zeit ergibt die Geschwindigkeit
        this.pos.add(this.vel.get().mult((float) delta)); // Die Geschwindigkeit multipliziert mit der Zeit ergibt die neue Position
    }

    // Funktion zum Zeichnen eines Körpers
    public void render() 
    {
        stroke(255); // Weiße Farbe
        circle(this.pos.x, this.pos.y, 5); // Zeichne einen Kreis an den aktuellen Koordinaten
        
        if(!this.name.equals("")) // Wenn ein Name gesetzt ist, zeichne auch diesen
            text(this.name, this.pos.x, this.pos.y);
    }

    //
    // Getter und Setter
    // Getter geben die Instanz der Klasse zurück, damit Getter-Funktionen aneinander gereiht werden können:
    // z.B.: new Body(1).set_velocity(10, 0).set_position(0, 0).set_name("Körper 1")
    //

    // Setzt die Beschleunigung
    public Body set_velocity(float vx, float vy)
    {
        this.vel.set(vx, vy);
        return this;
    }

    // Setzt die Position
    public Body set_position(float x, float y)
    {
        this.pos.set(x, y);
        return this;
    }

    // Setzt den Namen
    public Body set_name(String name) 
    {
        this.name = new String(name);
        return this;
    }
}