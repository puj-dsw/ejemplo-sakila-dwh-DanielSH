 
use sakila;


with datos_rental as (
select rental_id,
    MONTH(rental_date) as mes,
    YEAR(rental_date) as anno,
    CONCAT(customer.first_name, ' ', customer.last_name) as customer,
    title as film,
    CONCAT(district, ', ', city) as store,
    CONCAT(staff.first_name, ' ', staff.last_name) as staff
from rental
    join customer using(customer_id)
    join inventory using(inventory_id)
    join film using(film_id)
    join staff using(staff_id)
    join store on inventory.store_id = store.store_id
    join address on store.address_id = address.address_id
    join city on address.city_id = city.city_id
),


datos_tienda_pelicula as (
    select 
        store,
        film,
        sum(case when mes = 5 then 1 else 0 end) as mayo2005, -- mayo
        sum(case when mes = 6 then 1 else 0 end) as junio2005 -- junio
    from datos_rental
    group by store, film

),


datos_tienda_pelicula_analisis as (
    select 
        store,
        film,
        mayo2005,
        junio2005,
        junio2005 - mayo2005 as diferencia,
        (junio2005-mayo2005)/mayo2005 as porcentaje
    from datos_tienda_pelicula
    group by store, film

)



-- analisis 

select * from datos_tienda_pelicula_analisis limit 10;


 


