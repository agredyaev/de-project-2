# Проект 2

### Что сделать:
---
В таблице `shippings` содержится много дублирующейся и несистематизированной справочной информации. По сути там содержится весь лог доставки от момента оформления до выдачи заказа покупателю. Необходимо произвести миграцию в отдельные логические таблицы, а затем собрать на них витрину данных `shippings_datamart`

### Зачем: 
---
 Это поможет оптимизировать нагрузку на хранилище и позволит аналитикам, перед которыми стоит задача построить анализ эффективности и прибыльности бизнеса, отвечать на точечные вопросы о тарифах вендоров, стоимости доставки в разные страны, количестве доставленных заказов за последнюю неделю. Если искать эти данные в таблице исходных логов доставки, нагрузка на хранилище будет не оптимальна. Придется усложнять запросы, что может привести к ошибкам.

### За какой период: 
---
Все доступные данные

### Обновление данных:
---
Не требуется

### Необходимая структура:
---
![Требуемая модель данных](src\final_schema.png "Требуемая модель данных")

### Описание исходных полей:
* `shippingid` — уникальный идентификатор доставки
* `saleid` — уникальный идентификатор заказа. К одному заказу может быть привязано несколько строчек shippingid, то есть логов, с информацией о доставке
* `vendorid` — уникальный идентификатор вендора. К одному вендору может быть привязано множество saleid и множество строк доставки
* `payment` — сумма платежа (то есть дублирующаяся информация)
* `shipping_plan_datetime` — плановая дата доставки
* `status` — статус доставки в таблице shipping по данному shippingid. Может принимать значения `in_progress` — доставка в процессе, либо `finished` — доставка завершена.
* `state` — промежуточные точки заказа, которые изменяются в соответствии с обновлением информации о доставке по времени state_datetime.
    - booked (пер. «заказано»);
    - fulfillment — заказ доставлен на склад отправки;
    - queued (пер. «в очереди») — заказ в очереди на запуск доставки;
    - transition (пер. «передача») — запущена доставка заказа;
    - pending (пер. «в ожидании») — заказ доставлен в пункт выдачи и ожидает получения;
    - received (пер. «получено») — покупатель забрал заказ;
    - returned (пер. «возвращено») — покупатель возвратил заказ после того, как его забрал.
* `state_datetime` — время обновления состояния заказа.
* `shipping_transfer_description` — строка со значениями `transfer_type` и `transfer_model`, записанными через `:`. 
Пример записи — `1p:car`

* `transfer_type` — тип доставки. 
    - 1p означает, что компания берёт ответственность за доставку на себя, 
    - 3p означает, что за отправку ответственен вендор

* `transfer_model` — модель доставки, то есть способ, которым заказ доставляется до точки: 
    - car — машиной
    - train — поездом
    - ship — кораблем
    - airplane — самолетом
    - multiple — комбинированной доставкой.
    
* `shipping_transfer_rate` — процент стоимости доставки для вендора в зависимости от типа и модели доставки, который взимается интернет-магазином для покрытия расходов.
    
* `shipping_country` — страна доставки, учитывая описание тарифа для каждой страны.
    
* `shipping_country_base_rate` — налог на доставку в страну, который является процентом от стоимости payment_amount.
    
* `vendor_agreement_description` — строка, в которой содержатся данные `agreementid`, `agreement_number`, `agreement_rate`, `agreement_commission`, записанные через разделитель `:`. Пример записи — `12:vsp-34:0.02:0.023`.

* `agreementid` — идентификатор договора. 
* `agreement_number` — номер договора в бухгалтерии. 
* `agreement_rate` — ставка налога за стоимость доставки товара для вендора.
* `agreement_commission` — комиссия, то есть доля в платеже являющаяся доходом компании от сделки.

### Особенности данных:
--- 
Порядка 2% заказов исполняется с просрочкой, и это норма для вендоров. Вендор №3, у которого этот процент достигает 10%, скорее всего неблагонадёжен.
Около 2% заказов не доходят до клиентов.
В пределах нормы и то, что порядка 1.5% заказов возвращаются клиентами. При этом у вендора №21 50% возвратов. Он торгует электроникой и ноутбуками — очевидно, в его товарах много брака и стоит его изучить.

### План работ
---
1. Создать справочник стоимости доставки в страны `shipping_country_rates` из данных, указанных в `shipping_country` и `shipping_country_base_rate`, сделать первичный ключ таблицы — серийный id, то есть серийный идентификатор каждой строчки. Важно дать серийному ключу имя «id». Справочник должен состоять из уникальных пар полей из таблицы shipping

2. Создать справочник тарифов доставки вендора по договору shipping_agreement из данных строки vendor_agreement_description через разделитель :.
Названия полей:
    - agreementid,
    - agreement_number,
    - agreement_rate,
    - agreement_commission.

    Agreementid сделать первичным ключом.

3. Создать справочник о типах доставки `shipping_transfer` из строки `shipping_transfer_description` через разделитель `:`.

    Названия полей:
    - transfer_type,
    - transfer_model,
    - shipping_transfer_rate .

    Сделать первичный ключ таблицы — серийный id

4. Создать таблицу `shipping_info` с уникальными доставками `shippingid` и связать её с созданными справочниками `shipping_country_rates`, `shipping_agreement`, `shipping_transfer` и константной информацией о доставке `shipping_plan_datetime` , `payment_amount` , `vendorid`

5. Создать таблицу статусов о доставке `shipping_status` и включить туда информацию из лога shipping (status , state). Также добавить туда вычислимую информацию по фактическому времени доставки `shipping_start_fact_datetime`, `shipping_end_fact_datetime` . Отразить для каждого уникального shippingid его итоговое состояние доставки.

6. Создать представление shipping_datamart на основании готовых таблиц для аналитики и включить в него:
    - shippingid
    - vendorid
    - transfer_type — тип доставки из таблицы shipping_transfer
    - full_day_at_shipping — количество полных дней, в течение которых длилась доставка. Высчитывается как:shipping_end_fact_datetime-shipping_start_fact_datetime.
    - is_delay — статус, показывающий просрочена ли доставка. Высчитывается как:shipping_end_fact_datetime > shipping_plan_datetime → 1 ; 0
    - is_shipping_finish — статус, показывающий, что доставка завершена. Если финальный status = finished → 1; 0
    - delay_day_at_shipping — количество дней, на которые была просрочена доставка. Высчитыается как: shipping_end_fact_datetime >> shipping_end_plan_datetime → shipping_end_fact_datetime -− shipping_plan_datetime ; 0).
    - payment_amount — сумма платежа пользователя
    - vat — итоговый налог на доставку. Высчитывается как: payment_amount *∗ ( shipping_country_base_rate + agreement_rate + shipping_transfer_rate) .
    - profit — итоговый доход компании с доставки. Высчитывается как: payment_amount*∗ agreement_commission.