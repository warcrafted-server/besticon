local _, BI = ...

-- Búsqueda por intención: palabras que una persona escribe cuando piensa en una idea
-- (gracias, saludo, ayuda...) y que no aparecen en el nombre de ningún icono.
-- Cada concepto reúne esas palabras (español e inglés, sin tildes) y las palabras de
-- icono del catálogo que mejor lo representan. Se pueden añadir conceptos sin tocar la lógica.
BI.Concepts = {
    {
        words = { "gracias", "agradecer", "agradecimiento", "thanks", "thank", "thankyou", "gratitude" },
        icons = { "gift", "bouquet", "flower", "rose", "thanksgiving", "cornucopia" },
    },
    {
        words = { "saludo", "saludar", "hola", "hello", "greeting", "greet" },
        icons = { "bouquet", "rose", "flower", "kiss" },
    },
    {
        words = { "bienvenida", "bienvenido", "welcome" },
        icons = { "campfire", "tent", "hearthstone", "door" },
    },
    {
        words = { "adios", "despedida", "despedirse", "bye", "goodbye", "farewell" },
        icons = { "portal", "hearthstone", "ship", "kiss", "flower" },
    },
    {
        words = { "ayuda", "auxilio", "socorro", "help", "aid", "assist" },
        icons = { "bandage", "firstaid", "heal", "healing", "flare" },
    },
    {
        words = { "fiesta", "celebracion", "celebrar", "cumpleanos", "felicidades", "felicitar",
            "party", "celebrate", "birthday", "congratulations" },
        icons = { "cake", "party", "balloon", "firework", "celebration", "gift" },
    },
    {
        words = { "amor", "carino", "love" },
        icons = { "heart", "rose", "kiss", "flower", "bouquet" },
    },
    {
        words = { "brindis", "brindar", "cheers", "toast" },
        icons = { "beer", "ale", "wine", "mug", "goblet", "cup" },
    },
    {
        words = { "victoria", "ganar", "ganador", "victory", "win", "winner" },
        icons = { "trophy", "crown", "banner", "star", "flag" },
    },
    {
        words = { "peligro", "cuidado", "alerta", "warning", "danger", "alert" },
        icons = { "skull", "flare", "bell" },
    },
    {
        words = { "muerte", "morir", "muerto", "death", "dead" },
        icons = { "skull", "grave", "ghost" },
    },
    {
        words = { "paz", "amistad", "amigo", "peace", "friendship", "friend" },
        icons = { "peace", "flower", "rose" },
    },
    {
        words = { "musica", "cancion", "music", "song" },
        icons = { "drum", "horn", "bell", "trumpet", "song" },
    },
    {
        words = { "carta", "mensaje", "message", "letter" },
        icons = { "letter", "note", "scroll", "envelope", "card" },
    },
}
