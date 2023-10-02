-- https://github.com/puj-dsw/ejemplo-sakila-dwh-DanielSH/blob/main/scripts/ejercicios-desarrollados/02-10-2023/payments_store_analisis.sql

-- Objetivo: Consulta que nos muestre el pago promedio por cada alquiler agrupado por tienda y mostrando los resultados por mes (mayo, junio y julio de 2005). Luego se muestra algunas analíticas descriptivas (porcentaje de crecimiento y diferencia).

use sakila;


-- verificamos que contamos con la suma de todos los pagos de un rental
with payments_per_rental as (
    select
        rental_id,
        sum(amount) as total_pagos_per_rental,
        AVG(payment_date) as payment_date_avg,
        inventory_id 
    from payment
        join rental using(rental_id)
    group by rental_id
),


-- identificamos la cantidad de rentals y suma de los pagos por cada tienda agrupados por mes y año
-- nota: en la consulta anterior payment_date_avg representa el mes se va a encontrar un rental en nuestro análisis
payments_store_data as (
    select 
        store_id,
        city,
        district,
        YEAR(payment_date_avg) as anno,
        MONTH(payment_date_avg) as mes,
        sum(total_pagos_per_rental) as total_pagos,
        count(*) as qty_rentals
    from payments_per_rental
        join inventory using(inventory_id)
        join store using(store_id)
        join address using(address_id)
        join city using(city_id)
    group by store_id, mes, anno
),

-- obtención de datos en columnas para realizar operaciones más facilmente
payments_store_subset as (
    select 
        store_id,
        city,
        district,
        sum(case when anno = 2005 and mes = 5 then total_pagos else 0 end) as in_mayo2005, -- suma de dinero recibido por los rentals de mayo
        count(case when anno = 2005 and mes = 5 then total_pagos else null end) as rentals_mayo2005, -- cantidad de rentals en mayo
        
        sum(case when anno = 2005 and mes = 6 then total_pagos else 0 end) as in_junio2005, -- suma de dinero recibido por los rentals de junio
        count(case when anno = 2005 and mes = 6 then total_pagos else null end) as rentals_junio2005, -- cantidad de rentals en junio
        
        sum(case when anno = 2005 and mes = 7 then total_pagos else 0 end) as in_julio2005, -- suma de dinero recibido por los rentals de julio
        count(case when anno = 2005 and mes = 7 then total_pagos else null end) as rentals_julio2005 -- cantidad de rentals en julio

    from payments_store_data
    group by store_id
),

payments_store_analisis_preoperations as (
    select 
        store_id,
        city,
        district,
        in_mayo2005 / rentals_mayo2005 as avg_mayo2005,
        in_junio2005 / rentals_junio2005 as avg_junio2005,
        in_julio2005 / rentals_julio2005 as avg_julio2005
    from payments_store_subset
),


-- -- analiticas descriptivas
payments_store_analisis as (
    select 
        store_id,
        -- city,
        -- district,
        ROUND(avg_mayo2005, 2) as avg_mayo2005,
        ROUND(avg_junio2005, 2) as avg_junio2005,
        ROUND(avg_junio2005 - avg_mayo2005, 2) as diff_junio_mayo,
        CONCAT(ROUND(((avg_junio2005-avg_mayo2005)/avg_mayo2005)*100, 2), '%') as crecimiento_mayo_junio,
        ROUND(avg_julio2005, 2) as avg_julio2005,
        ROUND(avg_julio2005 - avg_junio2005, 2) as diff_julio_junio,
        CONCAT(ROUND(((avg_julio2005-avg_junio2005)/avg_junio2005)*100, 2), '%') as crecimiento_junio_julio

    from payments_store_analisis_preoperations
)



select * from payments_store_analisis limit 5;
