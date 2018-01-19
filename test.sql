select case
         when access_predicates is not null or filter_predicates is not null then
          '*' || id
         else
          '

 ' || id
       end as "Id",
       lpad(' ', level) || operation || ' ' || options "Operation",
       object_name "Name",
       cardinality "Rows",
       b.size_mb "Mb",
       case
         when object_type like '%TABLE%' then
          REGEXP_COUNT(a.projection, ']') || '/' || c.column_cnt
       end as "Column",
       access_predicates "Access",
       filter_predicates "Filter",
       case
         when object_type like '%TABLE%' then
          projection
       end as "Projection"
  from plan_table a,
       (select owner, segment_name, sum(bytes / 1024 / 1024) size_mb
          from dba_segments
         group by owner, segment_name) b,
       (select owner, table_name, count(*) column_cnt
          from dba_tab_cols
         group by owner, table_name) c
 where a.object_owner = b.owner(+)
   and a.object_name = b.segment_name(+)
   and a.object_owner = c.owner(+)
   and a.object_name = c.table_name(+)
 start with id = 0
connect by prior id = parent_id;
