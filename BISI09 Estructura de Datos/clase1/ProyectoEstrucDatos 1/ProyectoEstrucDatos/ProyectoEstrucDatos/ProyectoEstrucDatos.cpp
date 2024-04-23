#include <iostream>
#include <string>
#include <ctime>
#include "Hotel.h"
#include "Cliente.h"
#include "Reserva.h"
#include "ListaEnlazada.h"

using namespace std;

// Funciones para el m�dulo de Hoteles
void mostrarMenuHoteles();
void agregarHotel(ListaEnlazada<Hotel>& listaHoteles);
void mostrarTodosLosHoteles(ListaEnlazada<Hotel>& listaHoteles);
void buscarHotelPorCodigo(ListaEnlazada<Hotel>& listaHoteles);
void menuHoteles(ListaEnlazada<Hotel>& listaHoteles);

// Funciones para el m�dulo de Clientes
void mostrarMenuClientes();
void agregarCliente(ListaEnlazada<Cliente>& listaClientes);
void mostrarTodosLosClientes(ListaEnlazada<Cliente>& listaClientes);
void buscarClientePorCedula(ListaEnlazada<Cliente>& listaClientes);
void menuClientes(ListaEnlazada<Cliente>& listaClientes);

// Funciones para el m�dulo de Reservas
void mostrarMenuReservas();
void ingresarReserva(ListaEnlazada<Reserva>& listaReservas);
void visualizarTodasLasReservas(ListaEnlazada<Reserva>& listaReservas);
void buscarReservaPorCodigo(ListaEnlazada<Reserva>& listaReservas);
void actualizarReserva(ListaEnlazada<Reserva>& listaReservas);
void eliminarReserva(ListaEnlazada<Reserva>& listaReservas);
void menuReservas(ListaEnlazada<Reserva>& listaReservas);

// Funciones auxiliares
void mostrarMenu();
void limpiarListas(ListaEnlazada<Hotel>& listaHoteles, ListaEnlazada<Cliente>& listaClientes, ListaEnlazada<Reserva>& listaReservas);

int main() {
    ListaEnlazada<Hotel> listaHoteles;
    ListaEnlazada<Cliente> listaClientes;
    ListaEnlazada<Reserva> listaReservas;

    int opcion;
    do {
        mostrarMenu();
        cin >> opcion;
        cin.ignore(); // Limpiar el buffer del teclado

        switch (opcion) {
        case 1:
            menuHoteles(listaHoteles);
            break;
        case 2:
            menuClientes(listaClientes);
            break;
        case 3:
            menuReservas(listaReservas);
            break;
        case 4:
            // Reiniciar la aplicaci�n (limpiar todas las listas)
            limpiarListas(listaHoteles, listaClientes, listaReservas);
            cout << "�Aplicaci�n reiniciada con �xito!" << endl;
            break;
        case 5:
            // Acerca de
            cout << "Acerca de la aplicaci�n:" << endl;
            cout << "Desarrollado por: [Tu nombre]" << endl;
            cout << "Universidad: [Nombre de tu universidad]" << endl;
            cout << "Curso: [Nombre del curso]" << endl;
            cout << "Profesora: [Nombre de la profesora]" << endl;
            cout << "A�o: 2024" << endl;
            break;
        case 6:
            cout << "Saliendo de la aplicaci�n..." << endl;
            break;
        default:
            cout << "Opci�n no v�lida. Por favor, ingrese una opci�n v�lida." << endl;
            break;
        }
    } while (opcion != 6);

    return 0;
}

// Implementaciones de las funciones auxiliares

void mostrarMenu() {
    cout << "---- Men� Principal ----" << endl;
    cout << "1. Hoteles" << endl;
    cout << "2. Clientes" << endl;
    cout << "3. Reservas" << endl;
    cout << "4. Reiniciar la aplicaci�n" << endl;
    cout << "5. Acerca de" << endl;
    cout << "6. Salir" << endl;
    cout << "Ingrese su opci�n: ";
}

void limpiarListas(ListaEnlazada<Hotel>& listaHoteles, ListaEnlazada<Cliente>& listaClientes, ListaEnlazada<Reserva>& listaReservas) {
    listaHoteles.limpiar();
    listaClientes.limpiar();
    listaReservas.limpiar();
}

// Implementaciones de las funciones del m�dulo de Hoteles

void mostrarMenuHoteles() {
    cout << "---- Men� Hoteles ----" << endl;
    cout << "1. Agregar hotel" << endl;
    cout << "2. Mostrar todos los hoteles" << endl;
    cout << "3. B�squeda por c�digo de hotel" << endl;
    cout << "4. Volver al men� principal" << endl;
    cout << "Ingrese su opci�n: ";
}

void agregarHotel(ListaEnlazada<Hotel>& listaHoteles) {
    string codigo, nombre, pais, especializacion;
    int cantidadHabitaciones;

    cout << "Ingrese el c�digo del hotel: ";
    getline(cin, codigo);
    cout << "Ingrese el nombre del hotel: ";
    getline(cin, nombre);
    cout << "Ingrese el pa�s del hotel: ";
    getline(cin, pais);
    cout << "Ingrese la especializaci�n del hotel: ";
    getline(cin, especializacion);
    cout << "Ingrese la cantidad de habitaciones del hotel: ";
    cin >> cantidadHabitaciones;

    Hotel nuevoHotel(codigo, nombre, pais, especializacion, cantidadHabitaciones);
    listaHoteles.agregar(nuevoHotel);
    cout << "Hotel agregado correctamente." << endl;
}

void mostrarTodosLosHoteles(ListaEnlazada<Hotel>& listaHoteles) {
    cout << "---- Todos los Hoteles ----" << endl;
    listaHoteles.mostrar();
    cout << "Mostrando todos los hoteles..." << endl;
}

void buscarHotelPorCodigo(ListaEnlazada<Hotel>& listaHoteles) {
    string codigo;
    cout << "Ingrese el c�digo del hotel a buscar: ";
    getline(cin, codigo);

    Nodo<Hotel>* hotelEncontrado = listaHoteles.buscar(codigo);
    if (hotelEncontrado != nullptr) {
        cout << "Hotel encontrado:" << endl;
        cout << "C�digo: " << hotelEncontrado->dato.getCodigo() << endl;
        cout << "Nombre: " << hotelEncontrado->dato.getNombre() << endl;
        cout << "Pa�s: " << hotelEncontrado->dato.getPais() << endl;
        cout << "Especializaci�n: " << hotelEncontrado->dato.getEspecializacion() << endl;
        cout << "Cantidad de habitaciones: " << hotelEncontrado->dato.getCantidadHabitaciones() << endl;
    }
    else {
        cout << "No se encontr� ning�n hotel con el c�digo ingresado." << endl;
    }
}

void menuHoteles(ListaEnlazada<Hotel>& listaHoteles) {
    int opcion;
    do {
        mostrarMenuHoteles();
        cin >> opcion;
        cin.ignore(); // Limpiar el buffer del teclado

        switch (opcion) {
        case 1:
            agregarHotel(listaHoteles);
            break;
        case 2:
            mostrarTodosLosHoteles(listaHoteles);
            break;
        case 3:
            buscarHotelPorCodigo(listaHoteles);
            break;
        case 4:
            cout << "Volviendo al men� principal..." << endl;
            break;
        default:
            cout << "Opci�n no v�lida. Por favor, ingrese una opci�n v�lida." << endl;
            break;
        }
    } while (opcion != 4);
}

void agregarCliente(ListaEnlazada<Cliente>& listaClientes) {
    string cedula, nombre, metodoPago, tipoCliente, telefono;

    cout << "Ingrese el n�mero de c�dula del cliente: ";
    getline(cin, cedula);
    cout << "Ingrese el nombre del cliente: ";
    getline(cin, nombre);
    cout << "Ingrese el m�todo de pago del cliente (d�bito/cr�dito): ";
    getline(cin, metodoPago);
    cout << "Ingrese el tipo de cliente (Regular/VIP/Socio): ";
    getline(cin, tipoCliente);
    cout << "Ingrese el n�mero de tel�fono del cliente: ";
    getline(cin, telefono);

    Cliente nuevoCliente( "", cedula, nombre, metodoPago, tipoCliente, telefono);
    listaClientes.agregar(nuevoCliente);
    cout << "Cliente agregado correctamente." << endl;
}

void ingresarReserva(ListaEnlazada<Reserva>& listaReservas) {
    string codigo, fechaInicio, fechaFin, codigoHotel, cedulaCliente;

    cout << "Ingrese el c�digo de la reserva: ";
    getline(cin, codigo);
    cout << "Ingrese la fecha de inicio de la reserva (YYYY-MM-DD): ";
    getline(cin, fechaInicio);
    cout << "Ingrese la fecha de fin de la reserva (YYYY-MM-DD): ";
    getline(cin, fechaFin);
    cout << "Ingrese el c�digo del hotel: ";
    getline(cin, codigoHotel);
    cout << "Ingrese la c�dula del cliente: ";
    getline(cin, cedulaCliente);

    Reserva nuevaReserva(codigo, fechaInicio, fechaFin, codigoHotel, cedulaCliente);
    listaReservas.agregar(nuevaReserva);
    cout << "Reserva ingresada correctamente." << endl;
}

void visualizarTodasLasReservas(ListaEnlazada<Reserva>& listaReservas) {
    cout << "---- Todas las Reservas ----" << endl;
    listaReservas.mostrar();
}

void buscarReservaPorCodigo(ListaEnlazada<Reserva>& listaReservas) {
    string codigo;
    cout << "Ingrese el c�digo de la reserva a buscar: ";
    getline(cin, codigo);

    Nodo<Reserva>* reservaEncontrada = listaReservas.buscar(codigo);
    if (reservaEncontrada != nullptr) {
        cout << "Reserva encontrada:" << endl;
        cout << "C�digo: " << reservaEncontrada->dato.getCodigo() << endl;
        cout << "Fecha de inicio: " << reservaEncontrada->dato.getFechaInicio() << endl;
        cout << "Fecha de fin: " << reservaEncontrada->dato.getFechaFin() << endl;
        cout << "C�digo de hotel: " << reservaEncontrada->dato.getCodigoHotel() << endl;
        cout << "C�dula del cliente: " << reservaEncontrada->dato.getCedulaCliente() << endl;
    }
    else {
        cout << "No se encontr� ninguna reserva con el c�digo ingresado." << endl;
    }
}

void actualizarReserva(ListaEnlazada<Reserva>& listaReservas) {
    string codigo, nuevaFechaInicio, nuevaFechaFin;

    cout << "Ingrese el c�digo de la reserva a actualizar: ";
    getline(cin, codigo);
    cout << "Ingrese la nueva fecha de inicio de la reserva (YYYY-MM-DD): ";
    getline(cin, nuevaFechaInicio);
    cout << "Ingrese la nueva fecha de fin de la reserva (YYYY-MM-DD): ";
    getline(cin, nuevaFechaFin);

    Nodo<Reserva>* reservaEncontrada = listaReservas.buscar(codigo);
    if (reservaEncontrada != nullptr) {
        reservaEncontrada->dato.setFechaInicio(nuevaFechaInicio);
        reservaEncontrada->dato.setFechaFin(nuevaFechaFin);
        cout << "Reserva actualizada correctamente." << endl;
    }
    else {
        cout << "No se encontr� ninguna reserva con el c�digo ingresado." << endl;
    }
}

void eliminarReserva(ListaEnlazada<Reserva>& listaReservas) {
    string codigo;
    cout << "Ingrese el c�digo de la reserva a eliminar: ";
    getline(cin, codigo);

    listaReservas.eliminar(codigo); // Eliminar la reserva

    cout << "Reserva eliminada correctamente." << endl; // Mensaje de confirmaci�n
}

void menuReservas(ListaEnlazada<Reserva>& listaReservas) {
    int opcion;
    do {
        mostrarMenuReservas();
        cin >> opcion;
        cin.ignore(); // Limpiar el buffer del teclado

        switch (opcion) {
        case 1:
            ingresarReserva(listaReservas);
            break;
        case 2:
            visualizarTodasLasReservas(listaReservas);
            break;
        case 3:
            buscarReservaPorCodigo(listaReservas);
            break;
        case 4:
            actualizarReserva(listaReservas);
            break;
        case 5:
            eliminarReserva(listaReservas);
            break;
        case 6:
            cout << "Volviendo al men� principal..." << endl;
            break;
        default:
            cout << "Opci�n no v�lida. Por favor, ingrese una opci�n v�lida." << endl;
            break;
        }
    } while (opcion != 6);
}

// Implementaci�n de la funci�n menuClientes
void menuClientes(ListaEnlazada<Cliente>& listaClientes) {
    int opcion;
    do {
        mostrarMenuClientes();
        cin >> opcion;
        cin.ignore(); // Limpiar el buffer del teclado

        switch (opcion) {
        case 1:
            agregarCliente(listaClientes);
            break;
        case 2:
            mostrarTodosLosClientes(listaClientes);
            break;
        case 3:
            buscarClientePorCedula(listaClientes);
            break;
        case 4:
            cout << "Volviendo al men� principal..." << endl;
            break;
        default:
            cout << "Opci�n no v�lida. Por favor, ingrese una opci�n v�lida." << endl;
            break;
        }
    } while (opcion != 4);
}

// Implementaci�n de la funci�n mostrarMenuReservas
void mostrarMenuReservas() {
    cout << "---- Men� Reservas ----" << endl;
    cout << "1. Ingresar reserva" << endl;
    cout << "2. Visualizar todas las reservas" << endl;
    cout << "3. B�squeda por c�digo de reserva" << endl;
    cout << "4. Actualizar reserva" << endl;
    cout << "5. Eliminar reserva" << endl;
    cout << "6. Volver al men� principal" << endl;
    cout << "Ingrese su opci�n: ";
}
void mostrarMenuClientes() {
    cout << "---- Men� Clientes ----" << endl;
    cout << "1. Agregar cliente" << endl;
    cout << "2. Mostrar todos los clientes" << endl;
    cout << "3. B�squeda por n�mero de c�dula" << endl;
    cout << "4. Volver al men� principal" << endl;
    cout << "Ingrese su opci�n: ";
}

void mostrarTodosLosClientes(ListaEnlazada<Cliente>& listaClientes) {
    cout << "---- Todos los Clientes ----" << endl;
    listaClientes.mostrar();
}

void buscarClientePorCedula(ListaEnlazada<Cliente>& listaClientes) {
    string cedula;
    cout << "Ingrese el n�mero de c�dula del cliente a buscar: ";
    getline(cin, cedula);

    Nodo<Cliente>* clienteEncontrado = listaClientes.buscar(cedula);
    if (clienteEncontrado != nullptr) {
        cout << "Cliente encontrado:" << endl;
        cout << "N�mero de c�dula: " << clienteEncontrado->dato.getCedula() << endl;
        cout << "Nombre: " << clienteEncontrado->dato.getNombre() << endl;
        cout << "M�todo de pago: " << clienteEncontrado->dato.getMetodoPago() << endl;
        cout << "Tipo de cliente: " << clienteEncontrado->dato.getTipoCliente() << endl;
        cout << "N�mero de tel�fono: " << clienteEncontrado->dato.getTelefono() << endl;
    }
    else {
        cout << "No se encontr� ning�n cliente con el n�mero de c�dula ingresado." << endl;
    }
}