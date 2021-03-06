create or replace package body dbu_nobuf
as 
  
    function nvl2 (string_i  varchar2,
                 ifnotnull_i varchar2,
                 ifnull_i varchar2
                ) return varchar2
  as
  begin
    case 
        when string_i is null then  
          return ifnull_i;
        when string_i is not null then
          return ifnotnull_i;
    end case; 
  end nvl2;
  
  function desc_formatted (table_name_i varchar2, format_i varchar2 default 'CSV', table_owner_i varchar2 default user) 
  return pipe_type_t pipelined 
  as
      sql_l               varchar2(32000);
      
      header_l            varchar2(4000);
      pivoted_columns_l   varchar2(4000);
      output_l            varchar2(4000);

      col_count_l         number(3);
      
      pipe_o              pipe_type_t := pipe_type_t(); 
  begin
  
      sql_l := q'[      
      select {HEADER} from dual union all
      select {OUTPUT} from (
          select  
              col.column_name,
              col.data_type,
              decode(col.nullable, 'Y','','N','NOT NULL','') nullable,
              col.num_distinct,
              ind.index_name index_name,
              ind.column_position column_position,
              col.column_id
          from 
              all_tab_cols col,
              all_ind_columns ind
          where 
              col.table_name = '{TABLE_NAME}'
          and col.owner = '{TABLE_OWNER}'
          and ind.index_owner = '{TABLE_OWNER}'
          and col.table_name = ind.table_name (+)
          and col.column_name = ind.column_name (+)
          and col.column_id is not null
          )
          pivot 
          (
            min('##### '||column_position)
            for index_name in ( 
            {PIVOTED_COLUMNS} 
            )
      )]';
      
      select listagg(''''||index_name||''''||'as "'||index_name||'"',',') within group (order by index_name) 
      into pivoted_columns_l
      from  
          all_indexes
      where 
          table_name = table_name_i
      and owner = table_owner_i
      and index_name not like 'SYS%'
      ;
      
   
    case format_i 
    when 'CSV'
    then
    
        -- projection
        select listagg(index_name,'||'',''||') within group (order by index_name) 
        into output_l
        from  
            all_indexes
        where 
            table_name = table_name_i
        and owner = table_owner_i
        and index_name not like 'SYS%'
        ;
        
        output_l := q'[ column_name||','||data_type||','||nullable||','||num_distinct ]' 
                    || nvl2(output_l,'||'',''||'||output_l,'');
        
        
        -- header
        select listagg(index_name,',') within group (order by index_name) 
        into header_l
        from
            all_indexes
        where 
            table_name = table_name_i 
        and owner = table_owner_i
        and index_name not like 'SYS%'
        ;
        
        header_l := q'[ 'column_name,data_type,nullable,num_distinct]'
                    || nvl2(header_l,','||header_l,'')
                    ||'''';
    when 'MD'
    then
        -- projection
        select listagg(index_name,'||''|''||') within group (order by index_name) 
        into output_l
        from  
            all_indexes
        where 
            table_name = table_name_i
        and owner = table_owner_i
        and index_name not like 'SYS%'
        ;
        
        output_l := q'[ column_name||'|'||data_type||'|'||nullable||'|'||num_distinct ]' 
                    || nvl2(output_l,'||''|''||'||output_l,'');
        
        
        -- header
        select listagg(index_name,'|') within group (order by index_name) 
        into header_l
        from
            all_indexes
        where 
            table_name = table_name_i 
        and owner = table_owner_i
        and index_name not like 'SYS%'
        ;
        
        header_l := q'[ 'column_name|data_type|nullable|num_distinct]'
                    || nvl2(header_l,'|'||header_l,'')
                    ||'''';

        
        -- header delimiter
        select count(*)
        into col_count_l
        from
            all_indexes
        where 
            table_name = table_name_i 
        and owner = table_owner_i
        and index_name not like 'SYS%'
        ;


        header_l := header_l ||'||CHR(13)||CHR(10)||''';
        for i in 1..(col_count_l+4) 
        loop
            header_l := header_l ||'---';

            if i < (col_count_l + 4) 
            then 
                header_l := header_l || '|';
            end if;
            
        end loop;
    
    header_l := header_l ||'''';
    end case;
    
    
    
        
      
    sql_l := replace (sql_l, '{HEADER}',header_l);
    sql_l := replace (sql_l, '{PIVOTED_COLUMNS}',pivoted_columns_l);
    sql_l := replace (sql_l, '{OUTPUT}',output_l);
    sql_l := replace (sql_l, '{TABLE_NAME}',table_name_i);
    sql_l := replace (sql_l, '{TABLE_OWNER}',table_owner_i);
    
    dbms_output.put_line(sql_l);
    
    execute immediate sql_l 
    bulk collect into 
      pipe_o
    ;
    
    for i in pipe_o.first..pipe_o.last 
    loop
      pipe row (pipe_o(i));
    end loop;


end desc_formatted;


end dbu_nobuf;