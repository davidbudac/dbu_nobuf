# DBU_NOBUF
Quick and dirty utility functions.

## Installation
```
@src/dbu_nobuf.pks
@src/dbu_nobuf.pkb
```

## Function DESC_FORMATTED
Pipeline function returning DESC + INDEX matrix.

### Parameters 
- table_name_i
- format_i
  - `'CSV'` - comma separated values
  - `'MD'` - markdown table

### Example
```sql
select 
    column_value
from 
    table(dbu_nobuf.desc_formatted('MESSAGE_STATE','MD'))
```

### Output
column_name|data_type|nullable|num_distinct|IDX_FK_MESSAGE_TO_M_STATE|IDX_STATE_CODE_RELATION|PK_MESSAGE_STATE
---|---|---|---|---|---|---
MESSAGE_ID|NUMBER|NOT NULL|16717824|##### 1|##### 1|
CONTENT_ID|NUMBER||16740352||##### 3|
MESSAGE_TIME_STAMP|TIMESTAMP(6)|NOT NULL|17014784|##### 2|##### 2|##### 2
CODE|VARCHAR2|NOT NULL|8||##### 4|
TIME_STAMP|TIMESTAMP(6)|NOT NULL|63725568|||
ID|NUMBER|NOT NULL|65634304|||##### 1


### Advanced example
Getting description of tables accessed within a given query (SQL_ID)

```sql
with tabs as (
  select 
        distinct object_owner, object_name, sql_id
  from 
        v$sql_plan
  where 
        object_type like 'TABLE%'
)
select 
    case 
      when lag(object_name, 1, 'null') over (partition by object_name order by rownum) = object_name
      then ''
      else CHR(13)||CHR(10)||'## '||object_name||CHR(13)||CHR(10)
    end ||
    column_value
from 
    tabs,
    table(dbu_nobuf.desc_formatted(tabs.object_name,'MD', tabs.object_owner))
where 
    sql_id = 'aszh2799fmyms'
```

### Output

## MESSAGE_ACK_RELATION
column_name|data_type|nullable|num_distinct|IDX_FK_M_TO_M_RELATION_ACK|IDX_FK_M_TO_M_RELATION_MSG|PK_MESSAGE_RELATION|UQ_MESSAGE_RELATION
---|---|---|---|---|---|---|---
ACK_ID|NUMBER|NOT NULL|7558185|##### 1|||##### 3
MESSAGE_TIME_STAMP|TIMESTAMP(6)|NOT NULL|7470592||##### 2|##### 2|##### 2
ACK_TIME_STAMP|TIMESTAMP(6)|NOT NULL|7463936|##### 2|||##### 4
ID|NUMBER|NOT NULL|7558185|||##### 1|
MESSAGE_ID|NUMBER|NOT NULL|7558185||##### 1||##### 1
TIME_STAMP|TIMESTAMP(6)|NOT NULL|7558185||||

## MESSAGE_STATE
column_name|data_type|nullable|num_distinct|IDX_FK_MESSAGE_TO_M_STATE|IDX_STATE_CODE_RELATION|PK_MESSAGE_STATE
---|---|---|---|---|---|---
MESSAGE_ID|NUMBER|NOT NULL|16717824|##### 1|##### 1|
CONTENT_ID|NUMBER||16740352||##### 3|
MESSAGE_TIME_STAMP|TIMESTAMP(6)|NOT NULL|17014784|##### 2|##### 2|##### 2
CODE|VARCHAR2|NOT NULL|8||##### 4|
TIME_STAMP|TIMESTAMP(6)|NOT NULL|63725568|||
ID|NUMBER|NOT NULL|65634304|||##### 1

## SOURCE_MAPPING
column_name|data_type|nullable|num_distinct|PK_SOURCE_MAPPING
---|---|---|---|---
VALUE|VARCHAR2||2|
KEY|VARCHAR2|NOT NULL|4|##### 1

## STATE_MAPPING
column_name|data_type|nullable|num_distinct|PK_STATE_MAPPING
---|---|---|---|---
WEIGHT|NUMBER|NOT NULL|6|
KEY|VARCHAR2|NOT NULL|11|##### 1
VALUE|VARCHAR2||6|


