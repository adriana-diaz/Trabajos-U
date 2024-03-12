#include "Libro.h"
Libro::Libro(string titulo, double precio, string autor, string editorial, int anioPublicacion, string genero)
    : Publicacion(titulo, precio, autor) {
    this->editorial = editorial;
    this->anioPublicacion = anioPublicacion;
    this->genero = genero;
}

string Libro::getEditorial() const {
    return editorial;
}

int Libro::getAnioPublicacion() const {
    return anioPublicacion;
}

string Libro::getGenero() const {
    return genero;
}

void Libro::setEditorial(string editorial) {
    this->editorial = editorial;
}

void Libro::setAnioPublicacion(int anioPublicacion) {
    this->anioPublicacion = anioPublicacion;
}

void Libro::setGenero(string genero) {
    this->genero = genero;
}

double Libro::calcularPrecio() const {
    double precioFinal = precio; // Precio base

    // Aplicar tributaci�n si el libro tiene menos de 3 a�os de antig�edad
    if (2024 - anioPublicacion < 3) {
        precioFinal *= 1.05;
    }

    // Aplicar encarecimiento si el g�nero es aventura, fantas�a o medicina
    if (genero == "aventura" || genero == "fantas�a" || genero == "medicina") {
        precioFinal *= 1.02;
    }

    return precioFinal;
}