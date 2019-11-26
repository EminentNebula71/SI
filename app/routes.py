#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from app import app
from flask import render_template, request, url_for, redirect, session, make_response
import json
import os
import sys
import hashlib
import csv
import random


@app.route('/')
@app.route('/index', methods=['GET'])
def index():
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)
    return render_template('index.html', title = "Home", movies=catalogue['peliculas'])

@app.route('/buscar', methods=['GET', 'POST'])
def buscar():
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)
    movies = catalogue['peliculas']
    aux = list()
    for movie in movies:
        if request.form['Buscador'].lower() in movie['titulo'].lower() or request.form['Buscador'].lower() in movie['director'].lower():
            aux.append(movie)
        else:
            for actor in movie['actores']:
                if request.form['Buscador'].lower() in actor['personaje'].lower() or request.form['Buscador'].lower() in actor['nombre'].lower():
                    aux.append(movie)
    if len(aux) == 0:
        return render_template('index.html', title = "Home", movies=catalogue['peliculas'])
        
    return render_template('index.html', title = "Home", movies=aux)

@app.route('/categoria', methods=['GET', 'POST'])
def categoria():
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)
    movies = catalogue['peliculas']
    aux = list()
    for movie in movies:
        if request.form['Generos'] in movie['categoria']:
            aux.append(movie)
    if len(aux) == 0:
        return render_template('index.html', title = "Home", movies=catalogue['peliculas'])
        
    return render_template('index.html', title = "Home", movies=aux)


@app.route('/login', methods=['GET', 'POST'])
def login():
    # doc sobre request object en http://flask.pocoo.org/docs/1.0/api/#incoming-request-data
    if 'nombre' in request.form:
        # aqui se deberia validar con fichero .dat del usuario
        if os.path.isdir("usuarios/"+request.form['nombre']) == True:
            f = open("usuarios/"+request.form['nombre']+"/datos.dat", "r+")
            pw = request.form['contrasenia']
            pwmd5 = hashlib.md5()
            pwmd5.update(pw.encode("utf-8"))
            lista = list()
            for line in f:
                lista.append(line)
            if request.form['nombre'] in lista[0] and pwmd5.hexdigest() in lista[2]:
                session['usuario'] = request.form['nombre']
                session.modified=True
                # se puede usar request.referrer para volver a la pagina desde la que se hizo login
                return redirect(url_for('index'))
            else:
                # aqui se le puede pasar como argumento un mensaje de login invalido
                return render_template('login.html', title = "Sign In")
    else:
        # se puede guardar la pagina desde la que se invoca 
        session['url_origen']=request.referrer
        session.modified=True   
        # print a error.log de Apache si se ejecuta bajo mod_wsgi
        print (request.referrer, file=sys.stderr)
    return render_template('login.html', title = "Sign In", nombre = request.cookies.get('userid'))

@app.route('/logout', methods=['GET', 'POST'])
def logout():
    resp = make_response(redirect(url_for('index')))
    resp.set_cookie('userid', session['usuario'])
    session.pop('usuario', None)
    session.pop('carrito', None)
    return resp

@app.route('/registro', methods=['GET', 'POST'])
def registro():
    if 'nombre' in request.form:
        if os.path.isdir('usuarios/'+request.form['nombre']) == False and request.form['contrasenia'] == request.form['repetir']:
            os.mkdir("usuarios/"+request.form['nombre'])
            f = open("usuarios/"+request.form['nombre']+"/datos.dat", "w+")
            saldo = random.randrange(100, 500, 1)
            pw = request.form['contrasenia']
            pwmd5 = hashlib.md5()
            pwmd5.update(pw.encode("utf-8"))
            f.write(request.form['nombre']+"\n"+request.form['correo']+"\n"+pwmd5.hexdigest()+"\n"+request.form['tarjeta']+"\n"+str(saldo))
            f.close()
            f = open("usuarios/"+request.form['nombre']+"/historial.json", "w")
            f.write("{\"historial\":[]}")
            f.close()
            return redirect(url_for('index'))
        elif os.path.isdir('usuarios/'+request.form['nombre']) == True:
            return render_template('registro.html', title = "Registrate", flag=1)
        elif request.form['contrasenia'] != request.form['repetir']:
            return render_template('registro.html', title = "Registrate", flag=2)
    return render_template('registro.html', title = "Registrate")

@app.route('/detalles/<int:id>', methods=['GET', 'POST'])
def detalles(id):
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)
    for movie in catalogue['peliculas']:
        if movie['id']==id:
            return render_template('detalles.html', title = "Detalles", movie=movie)

@app.route('/aniadir', methods=['GET', 'POST'])
def aniadir():
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)
    if 'carrito' not in session:
        session['carrito'] = []

    aux = session['carrito']
    for movie in catalogue['peliculas']:
        if int(movie['id']) == int(request.args.get('id')):
            aux.append(movie['id'])
            session['carrito'] = aux
    return redirect(url_for('index'))

@app.route('/carrito', methods=['GET', 'POST'])
def carrito():
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)
    aux = list()
    precio = 0
    if 'carrito' not in session:
        session['carrito'] = []
    for movie in catalogue['peliculas']:
        for idz in session['carrito']:
            if int(idz) == int(movie['id']):
                aux.append(movie)
                precio += movie['precio']
    return render_template('carrito.html', title = "Carrito", movies = aux, precio = precio)

@app.route('/compra', methods=['GET', 'POST'])
def compra():
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)

    historial_data = open(os.path.join('usuarios/'+session['usuario']+'/historial.json'), encoding="utf-8").read()
    historial = json.loads(historial_data)

    historial_list = []
    dict_grande = {}

    f = open("usuarios/"+session['usuario']+"/datos.dat", "r+")
    lista =[]

    for line in f:
        lista.append(line)
    f.close()
    for idz in session['carrito']:
        for movie in catalogue['peliculas']:
            if int(idz) == int(movie['id']):
                if float(lista[4]) >= float(movie['precio']):
                    historial_dict = {}
                    historial_dict['id'] = movie['id']
                    historial_dict['titulo'] = movie['titulo']
                    historial_dict['precio'] = movie['precio']
                    historial_list.append(historial_dict)
                    session.pop('carrito', None)
                else:
                    return redirect(url_for('index'))
    lista[4] = float(lista[4]) - float(request.args.get('precio'))
    f = open("usuarios/"+session['usuario']+"/datos.dat", "w")
    f.write(lista[0]+lista[1]+lista[2]+lista[3]+str(lista[4]))


    dict_grande['historial'] = historial_list
    historial['historial'] = historial['historial']+dict_grande['historial']
    historial_data = open(os.path.join('usuarios/'+session['usuario']+'/historial.json'), encoding="utf-8", mode="w")
    json.dump(historial, historial_data)

    
    
    
    return redirect(url_for('index'))

@app.route('/historial', methods=['GET', 'POST'])
def historial():
    historial_data = open(os.path.join('usuarios/'+session['usuario']+'/historial.json'), encoding="utf-8").read()
    historial = json.loads(historial_data)
    return render_template('historial.html', title = "Historial", movies=historial['historial'])