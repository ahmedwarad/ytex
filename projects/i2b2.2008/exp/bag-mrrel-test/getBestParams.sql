delete from i2b2_2008_cv_best where experiment = 'bag-mrrel';

/* get the average f1 for each parameter combination */
drop table if exists tmp_param_f1;
create temporary table tmp_param_f1
as
select label, cost, avg(f1) f1, stddev(f1) stddevf1, avg(f1) - stddev(f1) f1s
from
(
  select label, cost, run, fold, avg(f1) f1
    from classifier_eval_irzv t
    inner join classifier_eval e on e.classifier_eval_id = t.classifier_eval_id
    inner join classifier_eval_svm l on e.classifier_eval_id = l.classifier_eval_id
    where name = 'i2b2.2008'
    and experiment in ('bag-mrrel')
    group by label, cost, run, fold
) s group by label, cost;

create unique index IX_paramf1 on tmp_param_f1(label, cost);

/* get the max f1 for each label */
insert into i2b2_2008_cv_best (label, experiment, f1)
select label, 'bag-mrrel', f1
from
(
	/*
	 * best f1 score by experiment (hotspot cutoff) and svm parameters
	 */
	select label, truncate(max(f1),3) f1
	from tmp_param_f1
	group by label
) s
;

/*
* apply the 1-standard-error rule
* get best f1 minus 1 stddev for each label
* truncate to 2 decimal places
*/
drop table if exists tmp_f1s;
create temporary table tmp_f1s
as
select s.label, truncate(min(f1s),2) f1s
from tmp_param_f1 s 
inner join i2b2_2008_cv_best c 
    on c.label = s.label 
    and s.f1 >= c.f1
    and c.experiment = 'bag-mrrel'
group by s.label
;

/*
* get the best f1 - 1 standard deviation
*/
drop table if exists cv_cost;
create temporary table cv_cost (label varchar(50), cost double)
select s.label, min(s.cost) cost
from tmp_param_f1 s 
inner join i2b2_2008_cv_best c 
    on c.label = s.label 
    and c.experiment = 'bag-mrrel'
inner join tmp_f1s f1s 
    on f1s.label = s.label
    and s.f1 >= f1s.f1s
group by s.label;

update i2b2_2008_cv_best b inner join cv_cost p on b.label = p.label set b.cost = p.cost
where b.experiment = 'bag-mrrel'
;

select cast(concat('label', label, '_train_data.kernel.evalLines=-t 0 -q -b 1 -c ', cost) as char(200))
from i2b2_2008_cv_best 
where experiment = 'bag-mrrel'
order by cast(label as decimal(2,0))
;