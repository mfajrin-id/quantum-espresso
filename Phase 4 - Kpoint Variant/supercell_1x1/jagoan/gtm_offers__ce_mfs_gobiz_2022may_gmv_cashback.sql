with campaign_pop_raw as (
  select 
    customer_id
    , customer.main_account_number AS account_number
    , customer.customer_cif as cif
    , gofood_jago_benefit_amount
  from `jago-bank-data-production`.`jago_gobiz_data_sharing`.`monthly_gobiz_eligible_merchant_benefit` 
    join `jago-bank-data-production`.`dbt_tests_results`.`data_analytics__datamart_base_customer` customer using(customer_id)
  where
    customer.customer_status = 'ACTIVE'
    and customer.main_account_number is not null
    and gofood_jago_benefit_flag is true
    and jakarta_month_start_date = '2022-05-01')

SELECT 
  account_number AS accountNumber
  , 'BC002' AS bankCode
  , cif
  , customer_id AS customerId
  , cast(gofood_jago_benefit_amount as numeric) as amount
  , TO_BASE64(SHA256(CONCAT(customer_id, gofood_jago_benefit_amount,'GoFood Commission Cashback', FORMAT_DATE("%Y-%m", current_date())))) AS idempotencyKey
  , STRUCT (
      STRUCT (
        'jago://digitalbanking.com/bell-notification/list' AS deepLink
        , 'https://jagobanking.onelink.me/9ryZ/69f9c122' AS webLink
      ) AS extra
    ) AS notificationPayload
FROM campaign_pop_raw
