use proyectosales
go
--Ahora que importamos el archivo excel, realizaremos unas consultas para conocer mas los datos

select top(10)* from ventas;

--Limitamos la salida con la funcion TOP,útil para cuando se tienen millones de filas y limitar los recursos.
--Otra cosa importante, cambiaremos los nombres de las tablas en las que hayan un espacio por un _ para evitarnos problemas con las consultas.
--Esto lo haremos usando el menú de sqlserver management Studio
--Tambien podemos cambiar el nombre de la columna mediante la funcion sp_rename, en este caso lo usamos para la columna Sub Category
sp_rename 'ventas.Sub Category', 'Sub_Category' , 'COLUMN';

--Hacemos una exploración de la data.

--Veremos si hay filas repetidas
select Order_ID,Product_ID,Sales, count(*) from ventas
group by Order_ID,Product_ID,Sales --En este caso solo necesitamos estos valores para distinguir una fila
having count(*) >1

--Notamos que existen dos filas iguales, esto probablemente sea porque cuando se compra un producto por una cantidad mayor a 1 , se genera un registro por cada producto individual con el mismo order_id
select * from ventas where Order_ID='US-2015-150119'

select distinct(Country) from ventas
--Observamos que la data solo es de Estados Unidos

select City,count(Sales)as VentasTotales from ventas
group by City
order by VentasTotales desc
---Observamos en que ciudades las ventas son mayores y cuanto es la cantidad


select State,sum(Sales)as VentasTotales from ventas
group by State
order by VentasTotales desc
---Igual que arriba pero ahora por estado y la ganancia total


select Category,count(Category)as VentasTotales from ventas
group by Category
order by VentasTotales desc
--Observamos solamente 3 tipos de categorias en las cuales mas se vendieron los materiales de oficina 


select min(Order_Date),max(Order_Date) from ventas
--Observamos que la data es desde el 2015 de Enero hasta el 2018 de Diciembre


--Veremos en que meses se obtienen mas ventas, usamos la funcion format para extraer el nombre del mes en la fecha
select FORMAT(Order_Date,'MMMM') as Mes , sum(Sales)as VentasTotales from ventas
group by FORMAT(Order_Date,'MMMM') 
order by VentasTotales desc
-- Observamos que se obtienen mas ventas en noviembre y diciembre, esto se debe al BlackFriday y Navidad


--Cuales son los  productos mas vendidos?
select 
Product_Name ,count(Product_Name) as Cantidad from ventas
group by Product_Name
order by Cantidad desc
--Estos son los productos que han sido vendidos mas veces sin embargo no es necesariamente el producto que mas ganancia ha generado.

--Productos con mas ganancias
select 
Product_Name ,sum(Sales) as VentasTotales from ventas
group by Product_Name
order by VentasTotales desc

--Cuales son los 10 productos mas vendidos?
select top(10)
Product_Name ,count(Product_Name) as Cantidad from ventas
group by Product_Name
order by Cantidad desc

-- Quienes son los clientes que han realizado mas compras?
select Customer_Name,count(Customer_ID)as Cantidad from ventas
group by Customer_Name

-- Quienes son los clientes que han gastado mas dinero?
select Customer_Name,sum(Sales)as Ganancia from ventas
group by Customer_Name
order by Ganancia desc

-- Quien es el top 1?

select top(1)
Customer_Name,sum(Sales)as Ganancia from ventas
group by Customer_Name
order by Ganancia desc


--Que subcategorias existen?
select count(distinct sub_category)as CantCategorias from ventas

-- Que subcategorias tuvieron mas ventas?
select Sub_category,count(Sub_category) as Cantidad from ventas
group by Sub_Category
order by Cantidad desc

--Que estados vendieron mas que Michigan(incluirlo tambien)?
select state,count(product_id) as Cantidad from ventas
group by State
having count(product_id) >= (select count(product_id) from ventas
							where State='Michigan'
						     )
order by Cantidad desc

-- Mostrar estado y sus ciudades con la ganancia generada
select state,city, sum(sales) as Ganancia from ventas
group by state,city
order by state,Ganancia desc

--creacion de vista--

create view producto_cantidad 
as select product_id, count(product_id)as cantidad from ventas
group by Product_ID

--Usando la función dense_rank()

select product_id,cantidad,dense_rank() over(order by cantidad desc)as rango from producto_cantidad

--Que producto es el tercer mas vendido?
--Subquery
select * from (
		select product_id,cantidad,dense_rank() over(order by cantidad desc)as rango from producto_cantidad
) as s
where s.rango = 3

