require 'pry'
require 'minitest/autorun'
require 'minitest/mock'
require 'consul_env'

CONSUL_RESPONSE = [{"LockIndex"=>0, "Key"=>"ALS/db/host", "Flags"=>0, "Value"=>"ZGJfaG9zdA==", "CreateIndex"=>16, "ModifyIndex"=>152},
 {"LockIndex"=>0, "Key"=>"ALS/db/name", "Flags"=>0, "Value"=>"ZGJfbmFtZQ==", "CreateIndex"=>18, "ModifyIndex"=>153},
 {"LockIndex"=>0, "Key"=>"ALS/db/user", "Flags"=>0, "Value"=>"ZGJfdXNlcg==", "CreateIndex"=>17, "ModifyIndex"=>155},
 {"LockIndex"=>0, "Key"=>"ALS/env/allosaurus_server", "Flags"=>0, "Value"=>"YWxsb3NhdXJ1c191cmw=", "CreateIndex"=>20, "ModifyIndex"=>149},
 {"LockIndex"=>0, "Key"=>"ALS/env/redis_url", "Flags"=>0, "Value"=>"cmVkaXNfdXJs", "CreateIndex"=>19, "ModifyIndex"=>148},
 {"LockIndex"=>0, "Key"=>"ALS/env/tomcat_server", "Flags"=>0, "Value"=>"dG9tY2F0X3VybA==", "CreateIndex"=>21, "ModifyIndex"=>151}]