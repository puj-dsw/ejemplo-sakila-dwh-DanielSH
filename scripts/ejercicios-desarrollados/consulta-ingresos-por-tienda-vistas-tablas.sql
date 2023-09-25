use sakila;

create  table if not exists t_datos_tienda as (
    select
        st.store_id,
        ad.address,
        ad.district,
        ci.city,
        co.country
    from store as st
        join address as ad using (address_id)
        join city as ci using (city_id)
        join country as co using (country_id)

);

create  table if not exists t_datos_pagos as (
    select 
        pa.payment_id,
        pa.amount,
        pa.payment_date,
        CONCAT(emp.first_name, ' ', emp.last_name) as staff,
        emp.store_id
    from payment as pa
        join staff as emp using(staff_id)
);

create  table if not exists t_datos_combinados as (
    select CONCAT(district, ' ', city) as store,
        country,
        year(payment_date) as year,
        month(payment_date) as month,
        amount
    from t_datos_pagos
        join t_datos_tienda using (store_id)
);


-- agrupar amount por store, year, month
create  table if not exists t_datos_por_mes as (
    select store, year, month, sum(amount) as total
    from t_datos_combinados
    group by store, year, month
);

-- select * 
-- from datos_por_mes
-- limit 3;

create  table if not exists t_datos_por_mes_columnas as (
    select 
        store,
        sum(case when year = 2005 and month = 5 then total else 0 end) as mayo2005, -- mayo
        sum(case when year = 2005 and month = 6 then total else 0 end) as junio2005 -- junio
    from t_datos_por_mes
    group by store
);

-- select * 
-- from datos_por_mes_columnas
-- limit 3;


create  table if not exists t_datos_por_mes_comparativo as (
    select 
        store,
        mayo2005,
        junio2005,
        junio2005 - mayo2005 as diferencia,
        ((junio2005 - mayo2005) / mayo2005) * 100 as porcentaje
    from t_datos_por_mes_columnas
);

select *
from t_datos_por_mes_comparativo;