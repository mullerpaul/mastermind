SET pages 50 lines 130
ALTER SESSION SET plsql_warnings='ENABLE:ALL' plscope_settings='IDENTIFIERS:ALL, STATEMENTS:ALL';
@mastermind_spec.sql
show errors
@mastermind_body.sql
show errors
