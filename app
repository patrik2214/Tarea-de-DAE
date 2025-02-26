PGDMP                     
    w            bdApp3    11.4    11.3 C    a           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            b           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            c           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            d           1262    25946    bdApp3    DATABASE     �   CREATE DATABASE "bdApp3" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Peru.1252' LC_CTYPE = 'Spanish_Peru.1252';
    DROP DATABASE "bdApp3";
             postgres    false            �            1255    26071    actualizarventa()    FUNCTION     |  CREATE FUNCTION public.actualizarventa() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	c int;
	d int;
BEGIN
	Select COUNT(*) INTO c FROM cliente
	inner join venta on cliente.codcliente=venta.codcliente
	inner join (SELECT * FROM pago WHERE pago.numventa=new.newventa) c on c.numventa=venta.numventa;

	Select COUNT(*) INTO d FROM cliente
	inner join venta on cliente.codcliente=venta.codcliente
	inner join (SELECT * FROM pago WHERE pago.numventa=new.numventa) c on c.numventa=venta.numventa
	WHERE c.estado=true;
	
	IF(d=c)THEN
		UPDATE venta SET estadopago=true WHERE numventa=new.numventa;
	END IF;
	
	return new;
END;
$$;
 (   DROP FUNCTION public.actualizarventa();
       public       postgres    false            �            1255    25947 4   cambio(integer, integer, integer, integer, smallint)    FUNCTION     5  CREATE FUNCTION public.cambio(codp1 integer, codp2 integer, cant integer, venta integer, des smallint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	c int;
	p decimal(8,2);
	sub decimal(8,2);
	
BEGIN
	SELECT cantidad INTO c FROM detalle WHERE codproducto=codp1 and numventa=venta;
	UPDATE producto SET stock=stock+c WHERE codproducto=codp1;
	DELETE FROM detalle WHERE  codproducto=codp1 and numventa=venta;
	SELECT precio INTO p FROM producto WHERE codproducto=codp2;
	INSERT INTO detalle VALUES(venta,codp2,cant,p,des,(p*cant),false);
	SELECT SUM(subtotal)into sub FROM detalle WHERE numventa=venta;
	UPDATE venta SET igv=0.18*sub, subtotal=sub-igv,total=sub WHERE numventa=venta;
	INSERT INTO cambio VALUES((SELECT COALESCE(max(codcambio),0)+1 from cambio),codp1,codp2,CURRENT_DATE);
	
END;
$$;
 f   DROP FUNCTION public.cambio(codp1 integer, codp2 integer, cant integer, venta integer, des smallint);
       public       postgres    false            �            1255    25949    comprobante(integer)    FUNCTION     �  CREATE FUNCTION public.comprobante(codventa integer) RETURNS TABLE(codigo integer, clienten character varying, direccion character varying, dni character, ruc character, producto character varying, cantidad integer, precio numeric, descuento smallint, subtotal numeric, fecha date, tipo boolean, comprobante integer)
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN 
		RETURN query
		SELECT venta.numventa,cliente.nombres,cliente.direccion,cliente.dni,cliente.ruc,producto.nomproducto,detalle.cantidad,detalle.precioventa,detalle.descuento,detalle.subtotal,pago.fecha_pago,venta.tipocomprobante,comprobante.codcomprobante
		FROM cliente INNER JOIN venta ON cliente.codcliente=venta.codcliente
		INNER JOIN comprobante ON comprobante.numventa=venta.numventa 
		INNER JOIN pago ON pago.numventa=venta.numventa 
		INNER JOIN detalle ON detalle.numventa=venta.numventa
		INNER JOIN producto ON producto.codproducto=detalle.codproducto
		WHERE venta.numventa=codventa;
	
END;
$$;
 4   DROP FUNCTION public.comprobante(codventa integer);
       public       postgres    false            �            1255    26070    detalle(integer)    FUNCTION     7  CREATE FUNCTION public.detalle(codventa integer) RETURNS TABLE(codigo integer, clienten character varying, direccion character varying, dni character, ruc character, producto character varying, cant integer, precio numeric, descu smallint, sub numeric, tipo boolean)
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN 
		RETURN query
		SELECT venta.numventa,cliente.nombres,cliente.direccion,cliente.dni,cliente.ruc,producto.nomproducto,detalle.cantidad,detalle.precioventa,detalle.descuento,detalle.subtotal,venta.tipocomprobante
		FROM cliente INNER JOIN venta ON cliente.codcliente=venta.codcliente
		INNER JOIN comprobante ON comprobante.numventa=venta.numventa 
		INNER JOIN detalle ON detalle.numventa=venta.numventa
		INNER JOIN producto ON producto.codproducto=detalle.codproducto
		WHERE venta.numventa=20; 
	
END;
$$;
 0   DROP FUNCTION public.detalle(codventa integer);
       public       postgres    false            �            1255    26065    deuda(character varying)    FUNCTION     |  CREATE FUNCTION public.deuda(documento character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	dato int;
BEGIN
	SELECT COUNT(*)into dato FROM pago
	INNER JOIN venta on venta.numventa=pago.numventa 
	INNER JOIN cliente on cliente.codcliente=venta.codcliente
	WHERE pago.tipo='credito' and cliente.dni=documento or cliente.ruc=documento;
	RETURN dato;
	
END;
$$;
 9   DROP FUNCTION public.deuda(documento character varying);
       public       postgres    false            �            1255    25950 ~   fn_cliente(character, character, character varying, character varying, character varying, character varying, boolean, integer)    FUNCTION     �  CREATE FUNCTION public.fn_cliente(dni character, ruc character, nombre character varying, telefono character varying, correo character varying, direccion character varying, vigencia boolean, tipo integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	cant integer;
BEGIN
	SELECT COUNT(*) INTO cant FROM cliente WHERE nombres=nombre;
	IF(cant=0)THEN
	
		IF (tipo=1)THEN
		INSERT INTO cliente VALUES((SELECT COALESCE(max(codCliente),0)+1 from CLIENTE), dni,NULL,nombre,telefono,correo,direccion,vigencia,tipo);
		END IF;
		
		IF (tipo=2)THEN
		INSERT INTO cliente VALUES((SELECT COALESCE(max(codCliente),0)+1 from CLIENTE), NULL,ruc,nombre,telefono,correo,direccion,vigencia,tipo);
		END IF;
		
		IF (tipo=3)THEN
		INSERT INTO cliente VALUES((SELECT COALESCE(max(codCliente),0)+1 from CLIENTE), dni,ruc,nombre,telefono,correo,direccion,vigencia,tipo);
		END IF;
		
	END IF;
END;
$$;
 �   DROP FUNCTION public.fn_cliente(dni character, ruc character, nombre character varying, telefono character varying, correo character varying, direccion character varying, vigencia boolean, tipo integer);
       public       postgres    false            �            1255    25951    fn_comprobante(integer)    FUNCTION     6  CREATE FUNCTION public.fn_comprobante(codventa integer) RETURNS TABLE(codigo integer, clienten character varying, cliente character varying, producto character varying, cantidad integer, precio numeric, descuento smallint, subtotal numeric, fecha date)
    LANGUAGE plpgsql
    AS $$
DECLARE
	valor boolean;

BEGIN
	SELECT tipocomprobante into valor FROM venta WHERE numventa=codventa;
	IF(valor)THEN 
		RETURN query
		SELECT venta.numventa,cliente.nombres,cliente.dni,producto.nomproducto,detalle.cantidad,detalle.precioventa,detalle.descuento,detalle.subtotal,pago.fecha_pago
		FROM cliente INNER JOIN venta ON cliente.codcliente=venta.codcliente
		INNER JOIN pago ON pago.numventa=venta.numventa 
		INNER JOIN detalle ON detalle.numventa=venta.numventa
		INNER JOIN producto ON producto.codproducto=detalle.codproducto
		WHERE venta.numventa=codventa;
	ELSE
		RETURN query
		SELECT venta.numventa,cliente.nombres,cliente.ruc,producto.nomproducto,detalle.cantidad,detalle.precioventa,detalle.descuento,detalle.subtotal,pago.fecha_pago
		FROM cliente INNER JOIN venta ON cliente.codcliente=venta.codcliente
		INNER JOIN pago ON pago.numventa=venta.numventa 
		INNER JOIN detalle ON detalle.numventa=venta.numventa
		INNER JOIN producto ON producto.codproducto=detalle.codproducto
		WHERE venta.numventa=codventa;
	
	END IF;
END;
$$;
 7   DROP FUNCTION public.fn_comprobante(codventa integer);
       public       postgres    false            �            1255    25952    fn_generarcod()    FUNCTION     �   CREATE FUNCTION public.fn_generarcod() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	codigo int;
BEGIN
	SELECT COALESCE(max(numventa),0)+1 INTO codigo FROM venta;
	return codigo;	
END;
$$;
 &   DROP FUNCTION public.fn_generarcod();
       public       postgres    false            �            1255    25953    fn_marcar(character varying)    FUNCTION     �   CREATE FUNCTION public.fn_marcar(nom character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	
BEGIN
	INSERT INTO marca VALUES((SELECT COALESCE(max(codMarca),0)+1 from marca),nom,true);	
END;
$$;
 7   DROP FUNCTION public.fn_marcar(nom character varying);
       public       postgres    false            �            1255    25954    fn_mo(integer)    FUNCTION     �  CREATE FUNCTION public.fn_mo(v integer) RETURNS TABLE(numero integer, fecha date, cliente character varying, total numeric, producto character varying, cantidad integer, descuento smallint)
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
	RETURN query
	SELECT venta.numventa,venta.fecha,cliente.nombres,venta.total,producto.nomproducto,detalle.cantidad,detalle.descuento
	FROM cliente INNER JOIN (SELECT*FROM venta WHERE numventa=v)venta on venta.codcliente=cliente.codcliente
	INNER JOIN detalle on detalle.numventa=venta.numventa
	INNER JOIN producto on producto.codproducto=detalle.codproducto
	ORDER BY producto.nomproducto ASC;
	
	
END;
$$;
 '   DROP FUNCTION public.fn_mo(v integer);
       public       postgres    false            �            1255    25955    fn_productom(numeric)    FUNCTION       CREATE FUNCTION public.fn_productom(preciox numeric) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
BEGIN
	return query
	SELECT producto.codproducto,producto.nomproducto,producto.precio from producto
	where vigencia=true and precio>=preciox;
	
END;
$$;
 4   DROP FUNCTION public.fn_productom(preciox numeric);
       public       postgres    false            �            1255    25956 
   fn_venta()    FUNCTION       CREATE FUNCTION public.fn_venta() RETURNS TABLE(totalv bigint, monto_total numeric, monto_max numeric, monto_min numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
	RETURN query
	SELECT COUNT(*) ,SUM(total) ,(SELECT MAX(total)), (SELECT MIN(total)) FROM venta;
	
END;
$$;
 !   DROP FUNCTION public.fn_venta();
       public       postgres    false            �            1255    25957    fn_ventas()    FUNCTION     �   CREATE FUNCTION public.fn_ventas() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	contador integer;
BEGIN
	SELECT COUNT(*) INTO contador FROM venta;
	RETURN contador;
	
END;
$$;
 "   DROP FUNCTION public.fn_ventas();
       public       postgres    false            �            1255    25958    fn_ventasm()    FUNCTION     �   CREATE FUNCTION public.fn_ventasm() RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	co decimal(8,2);
BEGIN
	SELECT MAX(total) INTO co FROM VENTA;
	RETURN co;
	
END;
$$;
 #   DROP FUNCTION public.fn_ventasm();
       public       postgres    false            �            1255    25959    fn_ventasmi()    FUNCTION     �   CREATE FUNCTION public.fn_ventasmi() RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	co decimal(8,2);
BEGIN
	SELECT MIN(total) INTO co FROM venta;
	RETURN co;
	
END;
$$;
 $   DROP FUNCTION public.fn_ventasmi();
       public       postgres    false            �            1255    25960    fn_ventasmo()    FUNCTION     �   CREATE FUNCTION public.fn_ventasmo() RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	co decimal(8,2);
BEGIN
	SELECT SUM(total) INTO co FROM venta;
	RETURN co;
	
END;
$$;
 $   DROP FUNCTION public.fn_ventasmo();
       public       postgres    false            �            1255    25961    informe_ventas(date, date)    FUNCTION     H  CREATE FUNCTION public.informe_ventas(fecha1 date, fecha2 date) RETURNS TABLE(codigo integer, fecha date, cliente character varying, monto_total numeric, subtotal numeric, igv numeric, estado boolean, tipo_pago character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN 
RETURN query
	SELECT venta.numventa,venta.fecha,cliente.nombres,venta.total,venta.subtotal,venta.igv,venta.estadopago,pago.tipo
	FROM cliente INNER JOIN venta ON venta.codcliente=cliente.codcliente 
	INNER JOIN pago ON pago.numventa=venta.numventa WHERE venta.fecha>=fecha1 and venta.fecha<=fecha2;
END;
$$;
 ?   DROP FUNCTION public.informe_ventas(fecha1 date, fecha2 date);
       public       postgres    false            �            1255    26063    listar_deuda(character varying)    FUNCTION     #  CREATE FUNCTION public.listar_deuda(documento character varying) RETURNS TABLE(cliente character varying, numventa integer, pago integer, fecha date, monto numeric, estado boolean)
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
	RETURN query
	SELECT cliente.nombres,pago.numventa,pago.codpago,pago.fecha_programada,pago.monto,pago.estado 
	FROM pago
	INNER JOIN venta on venta.numventa=pago.numventa 
	INNER JOIN cliente on cliente.codcliente=venta.codcliente
	WHERE pago.tipo='credito' and cliente.dni=documento or cliente.ruc=documento;
END;
$$;
 @   DROP FUNCTION public.listar_deuda(documento character varying);
       public       postgres    false            �            1259    25962    cambio    TABLE     �   CREATE TABLE public.cambio (
    codcambio integer NOT NULL,
    producto1 integer NOT NULL,
    producto2 integer NOT NULL,
    fecha date
);
    DROP TABLE public.cambio;
       public         postgres    false            �            1259    25965 	   categoria    TABLE     �   CREATE TABLE public.categoria (
    codcategoria integer NOT NULL,
    nomcategoria character varying(30) NOT NULL,
    descripcion character varying(100),
    vigencia boolean NOT NULL
);
    DROP TABLE public.categoria;
       public         postgres    false            �            1259    25968    cliente    TABLE     K  CREATE TABLE public.cliente (
    codcliente integer NOT NULL,
    dni character(8),
    ruc character(11),
    nombres character varying(30) NOT NULL,
    telefono character varying(13),
    correo character varying(50),
    direccion character varying(50) NOT NULL,
    vigencia boolean NOT NULL,
    codtipo integer NOT NULL
);
    DROP TABLE public.cliente;
       public         postgres    false            �            1259    25971    comprobante    TABLE     h   CREATE TABLE public.comprobante (
    codcomprobante integer NOT NULL,
    numventa integer NOT NULL
);
    DROP TABLE public.comprobante;
       public         postgres    false            �            1259    25974    detalle    TABLE     �   CREATE TABLE public.detalle (
    numventa integer NOT NULL,
    codproducto integer NOT NULL,
    cantidad integer NOT NULL,
    precioventa numeric(8,2) NOT NULL,
    descuento smallint NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    baja boolean
);
    DROP TABLE public.detalle;
       public         postgres    false            �            1259    25977 
   devolucion    TABLE     �   CREATE TABLE public.devolucion (
    numerodev integer NOT NULL,
    fecha date NOT NULL,
    motivo character varying(100) NOT NULL,
    montodev numeric(10,2) NOT NULL,
    atendidopor integer NOT NULL
);
    DROP TABLE public.devolucion;
       public         postgres    false            �            1259    25980    marca    TABLE     �   CREATE TABLE public.marca (
    codmarca integer NOT NULL,
    nommarca character varying(30) NOT NULL,
    vigencia boolean
);
    DROP TABLE public.marca;
       public         postgres    false            �            1259    25983    pago    TABLE     ,  CREATE TABLE public.pago (
    numventa integer NOT NULL,
    codpago integer NOT NULL,
    fecha_programada date,
    fecha_pago date,
    ingreso numeric(8,2) NOT NULL,
    vuelto numeric(8,2) NOT NULL,
    monto numeric(8,2) NOT NULL,
    tipo character varying(9),
    estado boolean NOT NULL
);
    DROP TABLE public.pago;
       public         postgres    false            �            1259    25986    producto    TABLE     C  CREATE TABLE public.producto (
    codproducto integer NOT NULL,
    nomproducto character varying(30) NOT NULL,
    descripcion character varying(100) NOT NULL,
    precio numeric(8,2) NOT NULL,
    stock integer NOT NULL,
    vigencia boolean NOT NULL,
    codmarca integer NOT NULL,
    codcategoria integer NOT NULL
);
    DROP TABLE public.producto;
       public         postgres    false            �            1259    25989    tipo_cliente    TABLE     n   CREATE TABLE public.tipo_cliente (
    codtipo integer NOT NULL,
    nombre character varying(20) NOT NULL
);
     DROP TABLE public.tipo_cliente;
       public         postgres    false            �            1259    25992    usuario    TABLE     T  CREATE TABLE public.usuario (
    codusuario integer NOT NULL,
    nomusuario character varying(20) NOT NULL,
    clave character varying(20) NOT NULL,
    nombrecompleto character varying(80) NOT NULL,
    cargo character varying(30),
    estado boolean NOT NULL,
    pregunta character varying(50),
    respuesta character varying(50)
);
    DROP TABLE public.usuario;
       public         postgres    false            �            1259    25995    venta    TABLE     %  CREATE TABLE public.venta (
    numventa integer NOT NULL,
    fecha date NOT NULL,
    total numeric(10,2) NOT NULL,
    subtotal numeric(10,2),
    igv numeric(10,2),
    tipocomprobante boolean NOT NULL,
    estadopago boolean NOT NULL,
    codcliente integer NOT NULL,
    baja boolean
);
    DROP TABLE public.venta;
       public         postgres    false            S          0    25962    cambio 
   TABLE DATA               H   COPY public.cambio (codcambio, producto1, producto2, fecha) FROM stdin;
    public       postgres    false    196   Vm       T          0    25965 	   categoria 
   TABLE DATA               V   COPY public.categoria (codcategoria, nomcategoria, descripcion, vigencia) FROM stdin;
    public       postgres    false    197   sm       U          0    25968    cliente 
   TABLE DATA               p   COPY public.cliente (codcliente, dni, ruc, nombres, telefono, correo, direccion, vigencia, codtipo) FROM stdin;
    public       postgres    false    198   n       V          0    25971    comprobante 
   TABLE DATA               ?   COPY public.comprobante (codcomprobante, numventa) FROM stdin;
    public       postgres    false    199   $o       W          0    25974    detalle 
   TABLE DATA               j   COPY public.detalle (numventa, codproducto, cantidad, precioventa, descuento, subtotal, baja) FROM stdin;
    public       postgres    false    200   �o       X          0    25977 
   devolucion 
   TABLE DATA               U   COPY public.devolucion (numerodev, fecha, motivo, montodev, atendidopor) FROM stdin;
    public       postgres    false    201   kp       Y          0    25980    marca 
   TABLE DATA               =   COPY public.marca (codmarca, nommarca, vigencia) FROM stdin;
    public       postgres    false    202   �p       Z          0    25983    pago 
   TABLE DATA               u   COPY public.pago (numventa, codpago, fecha_programada, fecha_pago, ingreso, vuelto, monto, tipo, estado) FROM stdin;
    public       postgres    false    203   q       [          0    25986    producto 
   TABLE DATA               z   COPY public.producto (codproducto, nomproducto, descripcion, precio, stock, vigencia, codmarca, codcategoria) FROM stdin;
    public       postgres    false    204   `r       \          0    25989    tipo_cliente 
   TABLE DATA               7   COPY public.tipo_cliente (codtipo, nombre) FROM stdin;
    public       postgres    false    205   ^s       ]          0    25992    usuario 
   TABLE DATA               t   COPY public.usuario (codusuario, nomusuario, clave, nombrecompleto, cargo, estado, pregunta, respuesta) FROM stdin;
    public       postgres    false    206   �s       ^          0    25995    venta 
   TABLE DATA               u   COPY public.venta (numventa, fecha, total, subtotal, igv, tipocomprobante, estadopago, codcliente, baja) FROM stdin;
    public       postgres    false    207   xt       �
           2606    25999    cambio cambio_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.cambio
    ADD CONSTRAINT cambio_pkey PRIMARY KEY (codcambio);
 <   ALTER TABLE ONLY public.cambio DROP CONSTRAINT cambio_pkey;
       public         postgres    false    196            �
           2606    26001    categoria categoria_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (codcategoria);
 B   ALTER TABLE ONLY public.categoria DROP CONSTRAINT categoria_pkey;
       public         postgres    false    197            �
           2606    26003    cliente cliente_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (codcliente);
 >   ALTER TABLE ONLY public.cliente DROP CONSTRAINT cliente_pkey;
       public         postgres    false    198            �
           2606    26005    comprobante comprobante_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.comprobante
    ADD CONSTRAINT comprobante_pkey PRIMARY KEY (codcomprobante);
 F   ALTER TABLE ONLY public.comprobante DROP CONSTRAINT comprobante_pkey;
       public         postgres    false    199            �
           2606    26007    devolucion devolucion_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.devolucion
    ADD CONSTRAINT devolucion_pkey PRIMARY KEY (numerodev);
 D   ALTER TABLE ONLY public.devolucion DROP CONSTRAINT devolucion_pkey;
       public         postgres    false    201            �
           2606    26009    marca marca_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.marca
    ADD CONSTRAINT marca_pkey PRIMARY KEY (codmarca);
 :   ALTER TABLE ONLY public.marca DROP CONSTRAINT marca_pkey;
       public         postgres    false    202            �
           2606    26011    pago pago_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_pkey PRIMARY KEY (codpago);
 8   ALTER TABLE ONLY public.pago DROP CONSTRAINT pago_pkey;
       public         postgres    false    203            �
           2606    26013    detalle pk_d 
   CONSTRAINT     ]   ALTER TABLE ONLY public.detalle
    ADD CONSTRAINT pk_d PRIMARY KEY (numventa, codproducto);
 6   ALTER TABLE ONLY public.detalle DROP CONSTRAINT pk_d;
       public         postgres    false    200    200            �
           2606    26015    producto producto_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (codproducto);
 @   ALTER TABLE ONLY public.producto DROP CONSTRAINT producto_pkey;
       public         postgres    false    204            �
           2606    26017    tipo_cliente tipo_cliente_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.tipo_cliente
    ADD CONSTRAINT tipo_cliente_pkey PRIMARY KEY (codtipo);
 H   ALTER TABLE ONLY public.tipo_cliente DROP CONSTRAINT tipo_cliente_pkey;
       public         postgres    false    205            �
           2606    26019    usuario usuario_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (codusuario);
 >   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
       public         postgres    false    206            �
           2606    26021    venta venta_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.venta
    ADD CONSTRAINT venta_pkey PRIMARY KEY (numventa);
 :   ALTER TABLE ONLY public.venta DROP CONSTRAINT venta_pkey;
       public         postgres    false    207            �
           2620    26072    pago tg_actualizarventas    TRIGGER     x   CREATE TRIGGER tg_actualizarventas AFTER UPDATE ON public.pago FOR EACH ROW EXECUTE PROCEDURE public.actualizarventa();
 1   DROP TRIGGER tg_actualizarventas ON public.pago;
       public       postgres    false    203    237            �
           2606    26023 %   comprobante comprobante_numventa_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.comprobante
    ADD CONSTRAINT comprobante_numventa_fkey FOREIGN KEY (numventa) REFERENCES public.venta(numventa);
 O   ALTER TABLE ONLY public.comprobante DROP CONSTRAINT comprobante_numventa_fkey;
       public       postgres    false    2768    199    207            �
           2606    26028    cliente fk_c_t    FK CONSTRAINT     y   ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT fk_c_t FOREIGN KEY (codtipo) REFERENCES public.tipo_cliente(codtipo);
 8   ALTER TABLE ONLY public.cliente DROP CONSTRAINT fk_c_t;
       public       postgres    false    2764    198    205            �
           2606    26033    detalle fk_d_p    FK CONSTRAINT     }   ALTER TABLE ONLY public.detalle
    ADD CONSTRAINT fk_d_p FOREIGN KEY (codproducto) REFERENCES public.producto(codproducto);
 8   ALTER TABLE ONLY public.detalle DROP CONSTRAINT fk_d_p;
       public       postgres    false    2762    200    204            �
           2606    26038    detalle fk_d_v    FK CONSTRAINT     t   ALTER TABLE ONLY public.detalle
    ADD CONSTRAINT fk_d_v FOREIGN KEY (numventa) REFERENCES public.venta(numventa);
 8   ALTER TABLE ONLY public.detalle DROP CONSTRAINT fk_d_v;
       public       postgres    false    200    2768    207            �
           2606    26043    producto fk_pro_cat    FK CONSTRAINT     �   ALTER TABLE ONLY public.producto
    ADD CONSTRAINT fk_pro_cat FOREIGN KEY (codcategoria) REFERENCES public.categoria(codcategoria);
 =   ALTER TABLE ONLY public.producto DROP CONSTRAINT fk_pro_cat;
       public       postgres    false    2748    204    197            �
           2606    26048    producto fk_pro_mar    FK CONSTRAINT     y   ALTER TABLE ONLY public.producto
    ADD CONSTRAINT fk_pro_mar FOREIGN KEY (codmarca) REFERENCES public.marca(codmarca);
 =   ALTER TABLE ONLY public.producto DROP CONSTRAINT fk_pro_mar;
       public       postgres    false    202    204    2758            �
           2606    26053    venta fk_v_c    FK CONSTRAINT     x   ALTER TABLE ONLY public.venta
    ADD CONSTRAINT fk_v_c FOREIGN KEY (codcliente) REFERENCES public.cliente(codcliente);
 6   ALTER TABLE ONLY public.venta DROP CONSTRAINT fk_v_c;
       public       postgres    false    2750    198    207            �
           2606    26058    pago pago_numventa_fkey    FK CONSTRAINT     }   ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_numventa_fkey FOREIGN KEY (numventa) REFERENCES public.venta(numventa);
 A   ALTER TABLE ONLY public.pago DROP CONSTRAINT pago_numventa_fkey;
       public       postgres    false    2768    207    203            S      x������ � �      T   �   x�e�M
1���)r �;�P�঴]�)I+x.��Ō�+ݽ��}o�42�.�0h�RX1#�O��0Q��1kH,�wV�c$������)�%�B���J�n�MCO�Ƭ�x�Ve	�z>��k���X���m���u���m}�{C�K��>�I7      U   �   x�M�MN�0���)|�Q~�v�4BHh�`6����4�t��\���(??˟�c��NZ�j8>�>�zz'<�R�z��Y������s
�Zk�����7��@�_����2F|z��R�:�,L�j�y�(�ݐ'��iAcӌ`�f��vMs�P�=�:g�|������a3�(=%��9\�[6^+-��+�����w����7��J���v�����Ʌ�l,��qc�/�E������z���J,.�)q�	!��Xf�      V   f   x�˹@�����^��I6[A,'̅ɃŋˇC<JР*5�;������Yg\q�o|�w�}�w�}���}�Q�>(�U�~H� }.�      W   �   x�u�M�0���0��%z�=A�?�*�΄q��ǟd�6�#x�jz��Π�s�zM�wu�ћ���v����/����� ���W�:��a�F�ї��22��E��� ֙޳�$�C�vD˞�p�S���B׉$Mjyw}y'æ�Ǵ��`�S;��OӜ=[8cJ��������ox��~�VJ�W�y      X   ?   x�3�420��54�52�
uur�44453�30�4�2B�.(*MMJ4�4740�3I��qqq ��      Y   O   x�3�t-(���,�2�N�-.�K��9}܁�	�Oj^~Y>�i��X\Zd�rz:�r�q�sz敤� E,8=�T� I��      Z   7  x���Mn� ��p����s�� �(i�n���U���A-bcy��ɐgC@pyFJ�P3����:�_����M1p8ɑ/�-n�v�[�uh��;��_@��wmujă/yҜ��!HF
,�������b�dyg����?T��F���mYR0g�������EL��C��k�	/����^�3q�D։_$����L���d��L�oF,��~�l\%e8���9ڟ���9ڟ���9ڟ���9ڟ�������з?;.<�s���y�5%|�>t*���*Y-,.���-��QJ� ̀d�      [   �   x�M�1k�0��ӯ�-��$�v�T�P1�vh�.�-��3����`W�v�x���)���H/�O��]���(Ue	5D X��=͞z���g͈�h ��+����59M�hZf4�`/��J�r��
��|���K,_8��ٛ@^�i������uQ��z��Й���(�]��x�Zp���w���	�e7º��t��� be{\hA1�lqL-�/E��L5~
��5	fY      \   9   x�3��S�K,)-J��2q�J��M�LN�2�H-*��KTH��S
u����� ���      ]   �   x�%�Aj�0EףS�%v���"`b0t��D��k&�$Cr��"��n�����e�Q�f,��`B{>�O$Q�?�J�rV�\���ڨ>�R4>�n��;���� �_�f�M�ƌ��Ea��H�mf( ����J�	s�V����u�1�@�oa�(~&��?��(�����
\#ƿ�`���V8rBw�pν fGN�      ^     x���A�� �5�K#���Ĝ�� �׀!,fԨ����90�^�W� ��j�Og8B
��P�@�O��Y?�Ƴe'=6��-�Pհ�"E�#D�m>*�Ӎs(�m3�Lܛ��ܒS� 3$��L{_�>_���?��m�X�5pոZl3�D�Wq�dЃ��U�ۨ�e��&�8.ؔ��"�u$o��D�W��t�u=�\ڷy$���̶�G޹&��d����:kPf��r��ƶ���1��'�CK���;�%7���<f]�{߶�T��     