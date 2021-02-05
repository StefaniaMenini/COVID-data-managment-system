/*1. Create a report to show the percentage of the recipients covered by an accepted health care insurance plan and the percentage of those who are not (billing purposes).
The following report might be demanded by the billing department, whose director wishes to check that each hospital service has been properly charged to each insurance provider. 
This data might also be provided to the finance department for the creation of any audit report.
Following the SQL query displays recipients’ insurance details to highlight who has an active insurance and which is the provider: */
SELECT recipients.recipient_id as "Recipient_Id", recipients.first_name as "First Name", recipients.last_name as "Last Name", insurance.card_number as "Card Number", insurance.insurance_provider as "Insurance Provider"
FROM recipients
LEFT JOIN insurance ON recipients.recipient_id = insurance.recipient_id
ORDER BY recipients.first_name, recipients.last_name;

/* 2. Creation of a report that shows how many COVID vaccine doses are administered daily. How many first and second doses have been administered?
Both COVID vaccine providers require 2 doses to offer the full vaccine benefits and according to the scientists the first dose only helps with the immune system creates a response and the 
2nd dose will further boot the response for long-term protection. The Nurse Manager wants to make sure the vaccines are being administrated daily to meet the government requirements. 
As well as needs to know how many appointments are scheduled to assign a shift to the team. Following the SQL query used to create a report that shows the number of first doses administrated: */
SELECT count(1) as "Number of First Doses Administrated", first_dose_date as "First Administration Date" FROM administrations
WHERE first_dose_date IS NOT NULL
GROUP BY first_dose_date
ORDER BY count(1) DESC;

/*Following the SQL query used to create a report that shows the number of first doses administrated:*/
SELECT count(1) as "Second Doses Administrated", second_dose_date as "Second Administration Date" FROM administrations
WHERE second_dose_date IS NOT NULL
GROUP BY second_dose_date
ORDER BY count(1) DESC;

/* 3. Creation of a report that shows all those recipients who are waiting for the administration of the 2nd dose. When are they scheduled for the 2nd shot? How many days are left from 2nd dose appointment?
This report is for ordering purposes and for the admin manager overseeing the vaccination appointments to guarantee all patients are being vaccinated. Especially, to confirm that all recipients waiting for the 2nd dose are prioritized to receive the full vaccine benefits, following the vaccine providers' indications. For example, once all the appointments have been scheduled, the number of recipients booked for the following days can be compared with the number of doses left in the storage. In case of a vaccine shortage, an order will be placed by the administration department to avoid potential delays.
Following the SQL query used to create the report: */
SELECT recipient_id as "Recipient Id", first_name as "First Name", last_name as "Last Name", scheduled_appt as "Scheduled Appointment", datediff(date(now()), scheduled_appt) as Days_Remaining
FROM recipients
WHERE scheduled_appt IS NOT NULL
AND scheduled_appt IN (SELECT scheduled_appt FROM recipients
WHERE scheduled_appt > date(now())) ORDER BY Days_Remaining ASC;

/* 4. Creation of a report that shows how many vaccine providers are supplying the Federally Qualified Health Center. Show how many vaccine doses are left in the inventory. When will it be necessary to place a new order from one of the providers?
The COVID vaccines will be overseen by a centralized system and ordered through CDC. To avoid any vaccine shortage and to allow a proper storage administration, the inventory manager will need a detailed report of each storage unit.
Following the SQL query used to create the report that shows how many providers are supplying the facility: */
SELECT count(distinct provider_name) as "Number of Vaccines' Providers" 
FROM batch;

/* Following the SQL query used to show how many are left in the inventory group by the vaccine provider: */
SELECT batch.provider_name as "Vaccine Provider Name", storage.doses_used as "Doses Administrated", storage.inventory as "Doses Left" FROM batch, orders, storage
WHERE batch.batch_id = orders.batch_id
AND orders.order_no = storage.order_no
ORDER BY storage.doses_used DESC;

/* Since inventory will be periodically checked and it might be time-consuming, creating a view will speed up this procedure. Below the code used to create the view: */
CREATE VIEW storage_overview AS (
SELECT batch.provider_name as "Vaccine Provider Name", storage.doses_used as "Doses Administrated", storage.inventory as "Doses Left" FROM batch, orders, storage
WHERE batch.batch_id = orders.batch_id
AND orders.order_no = storage.order_no
ORDER BY storage.doses_used DESC);

/* Once the view is created, the inventory manager will just need use the latter to pull up the bi-weekly or monthly reports for the storage without going into any hassle.*/
SELECT *
FROM storage_overview;

/* 5. Creation of a report that shows any recipient that has experienced side-effects after the 1st dose or the 2nd dose by provider name. */
SELECT recipient_id as "Recipient Id", health_report as "Experienced Side-Effects", first_dose_date as "First Administration Date", second_dose_date as "Second Administration Date"
FROM administrations
WHERE health_report != "Nothing"
ORDER BY first_dose_date, second_dose_date DESC;

/* 6. Create a report of side effects based on the vaccine administrated?
Creation of a report that shows any recipients that has experienced severe COVID after the first dose or the second dose.
This report is for the provider to monitor the effectiveness of the vaccine. Is it still likely that patients still contract severe COVID symptoms after having received the 1 or 2 doses of the vaccine? 
According to a report sent out the last week of December, 21 cases of anaphylaxis have been reported after the administration of the Pfizer-BioNTech COVID-19 vaccines. 
It is important to know which provider’s vaccine gave the side effect to monitor the efficacy and effects of the vaccine to the individuals health. This report will also benefit any Vaccine Research Center 
to advance the investigation of the virus and the Government to manage the pandemic with the new board in the seat. */
SELECT batch.provider_name as "Provider Name", administrations.health_report as "Experienced Side-Effects" FROM recipients, administrations, batch
WHERE recipients.recipient_id = administrations.recipient_id
AND administrations.batch_id = batch.batch_id
AND recipients.status IN ("Vaccinated", "Fully Vaccinated")
ORDER BY batch.provider_name, administrations.health_report ASC;

/* 7. Create a report that shows any death that has happened after being fully vaccinated and where COVID has been diagnosed. Which COVID vaccine did they receive?
Authorities are investigating the deaths of people due to COVID even after being vaccinated. Therefore, the District officials need a report from any Health Care Center of all the deceased patients and which 
vaccine they received. This report might help any COVID research center monitor not only the vaccine efficiency but also the virus response to treatment. */
SELECT recipients.recipient_id as "Recipient Id", recipients.deceased as "Deceased after Vaccinationed", batch.provider_name as "Vaccine Provider" FROM recipients, administrations, batch
WHERE recipients.recipient_id = administrations.recipient_id
AND administrations.batch_id = batch.batch_id
AND status = "Fully Vaccinated" AND deceased = "Yes";

/* 8. Creation of a report that shows how many recipients have been fully vaccinated. The report has to display the number of males, females, and their ethnicity.
After the FDA approves the vaccine, they continue to oversee the administration and safety. This report is for CDC to know how many vaccines have been given to the public. */
SELECT count(1) as "Recipients Count", sex as "Gender", ethnicity as "Ethnicity" FROM recipients
WHERE status = "Fully Vaccinated"
GROUP BY sex, ethnicity
ORDER BY sex, ethnicity DESC;

/* 9. Creation of a report that shows how many recipients have been vaccinated in Middlesex county.
The district officials might want to know how many recipients have been fully vaccinated in their county and ask each health care facility to produce a report. The latter could also help each state monitoring 
the advancement of the COVID mass vaccination with the primary goal of having all the citizens of age 65 and above vaccinated in the next couple of months. */
SELECT recipient_id as "Recipient Id", age as "Recipient Age", status as "Recipient Status", county as "County" FROM recipients
WHERE status = "Fully Vaccinated"
AND county = "Middlesex";

/* 10. Is the Health Care Center in line with the vaccine administration state regulations? Are people over 65 being vaccinated? If not, there is any reason in the recipient's medical history. */
SELECT round(std(age),2) as "Age Standard Deviation", round(avg(age), 0) as "Average Age", sex as "Recipient Gender" FROM recipients
GROUP BY sex;

/* On average, the male recipients have an age of 60 years old, while female recipients an age of 58. However, the standard deviation seems to show some data points far away from the average, 
highlighting the presence of potential outliers. In the case of outliers, might be useful the creation of a report that shows the medical history of the recipient to investigate the reason for 
the vaccine administration. */
SELECT recipient_id as "Recipient Id", age as "Recipient Age", sex as "Recipient Gender", medical_history as "Recipient Medical Hystory" FROM recipients
WHERE age < 60
ORDER BY age ASC;






