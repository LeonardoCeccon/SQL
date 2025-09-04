-- Querry 1

WITH leads AS (
    select 
        date_trunc('month', visit_page_date)::date as visit_page_month,
        count(*) as visit_page_count
    from sales.funnel
    group by visit_page_month
),
payments AS (
    select 
        date_trunc('month', fun.paid_date)::date as paid_month,
        count(fun.paid_date) as paid_count,
        sum(pro.price * (1 + fun.discount)) as receita
    from sales.funnel as fun
    left join sales.products as pro
        on fun.product_id = pro.product_id
    where fun.paid_date is not null
    group by paid_month
)

select 
    leads.visit_page_month as "mês", 
    leads.visit_page_count as "leads (#)",
    payments.paid_count as "vendas (#)",
    (payments.receita)/1000 as "receita (k, R$)",
    round((payments.paid_count::numeric / leads.visit_page_count::numeric) * 100, 2) as "conversao (%)",
    round((payments.receita::numeric / payments.paid_count) / 1000, 2) as "ticket médio (k,R$)"
from leads 
left join payments 
    on leads.visit_page_month = payments.paid_month
order by leads.visit_page_month;

-- Query 2

select 
    'Brazil' as país,
    cus.state as estado,
    count(fun.paid_date) as "vendas (#)"
from sales.funnel as fun
left join sales.customers as cus
    on fun.customer_id = cus.customer_id
where fun.paid_date between '2021-08-01' and '2021-08-31'
group by país, estado
order by "vendas (#)" desc
limit 5;

-- Query 3

select
    pro.brand as marca,
    count(fun.paid_date) as "vendas(#)"
from sales.funnel as fun
left join sales.products as pro
    on fun.product_id = pro.product_id
where fun.paid_date between '2021-08-01' and '2021-08-31'
group by marca 
order by "vendas(#)" desc
limit 5;

-- Querry 4

select
    sto.store_name as loja,
    count(fun.paid_date) as "vendas(#)"
from sales.funnel as fun
left join sales.stores as sto
    on fun.store_id = sto.store_id
where fun.paid_date between '2021-08-01' and '2021-08-31'
group by loja
order by "vendas(#)" desc
limit 5;

-- Query 5

select
    extract('dow' from visit_page_date) as "dia_semana",
    case 
        when extract('dow' from visit_page_date) = 0 then 'domingo'
        when extract('dow' from visit_page_date) = 1 then 'segunda'
        when extract('dow' from visit_page_date) = 2 then 'terça'
        when extract('dow' from visit_page_date) = 3 then 'quarta'
        when extract('dow' from visit_page_date) = 4 then 'quinta'
        when extract('dow' from visit_page_date) = 5 then 'sexta'
        when extract('dow' from visit_page_date) = 6 then 'sábado'
    end as "dia da semana",
    count(*) as "visitas (#)"
	
from sales.funnel
where visit_page_date between '2021-08-01' and '2021-08-31'
group by "dia_semana", "dia da semana"
order by "dia_semana";
