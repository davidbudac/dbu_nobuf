create or replace package dbu_nobuf as
       
  type pipe_type_t is varray(10000) of varchar2(4000);

      
      
  -- DESC
  function desc_formatted (table_name_i varchar2, format_i varchar2 default 'CSV', table_owner_i varchar2 default user) 
  return pipe_type_t pipelined ;

end dbu_nobuf;