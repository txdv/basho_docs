---
title: Using Commit Hooks
project: riak
version: 1.4.2+
document: tutorials
toc: true
audience: beginner
keywords: [developers, commit-hooks]
---

## 概述

pre-commit 和 post-commit 钩子分别在 riak_object 持久存储前后调用，可以大大增强应用程序的功能。commit 钩子可以：

- 不修改写入的对象
- 修改对象
- 终止更新，禁止一切修改

Post-commit 在存储完成后调用，不应该修改 riak_object。在 post-commit 中修改 riak_object 可能导致回馈循环，最终形成无限循环，除非钩子函数编写的很小心，提供了终止这种循环的功能。

pre-commit 和 post-commit 钩子在各 bucket 中定义，存在 bucket 的属性中。每次成功响应客户端时都会调用这两个钩子。

## 设置

pre-commit 和 post-commit 钩子的设置都很简单，直接把钩子函数的引用加入 bucket 的钩子函数列表即可。pre-commit 钩子存储在 bucket 的  *precommit* 属性中。post-commit 钩子存储在 bucket 的 *postcommit* 属性中。

pre-commit 钩子可以使用具名 JavaScript 函数或 Erlang 函数编写。各自的设置如下：

Javascript：`{"name": "Foo.beforeWrite"}`
Erlang：`{"mod": "foo", "fun": "beforeWrite"}`

post-commit 钩子只能使用 Erlang 编写，详细内容请阅读“[[commit 钩子高级用法|Advanced Commit Hooks]]”。之所以制定这个限制是因为 JavaScript 不能调用 Erlang 代码，因此也就不能做什么有用的工作。当我们增强了 Erlang/JavaScript 集成程度后，会再重新审视这个限制。post-commit 钩子使用的函数引用句法和 pre-commit 一样。

定义 JavaScript 具名函数的步骤请参阅“[[高级 MapReduce 用法|Advanced MapReduce]]”。

## Pre-Commit 钩子

### API 和行为表现

pre-commit 钩子函数应该接受一个参数，即要修改的 riak_object。还记得吗，删除也被认为是一种“写入操作”，所以删除对象时也会调用 pre-commit 钩子。如果执行删除操作，钩子函数应该检查对象是否具有 *X-Riak-Deleted* 元数据。

使用 Erlang 编写的 pre-commit 函数可以有三种返回结果：

- 一个 riak_object -- 可以返回传入的对象，或者修改后的对象。允许在对象写入之前对其进行修改
- `fail` -- 禁止 Raik 写入对象，并返回“403 Forbidden”和错误消息告知为什么终止了写入
- `{fail, Reason}` -- `{fail, Reason}` 元组和第 2 类返回结果一样，只是会把 `Reason` 作为错误消息

在处理 Erlang pre-commit 钩子时发生的错误会写入 `sasl-error.log` 日志文件，每行以“problem invoking hook”开头。

##### Erlang Pre-commit 示例

```erlang
%% Limits object values to 5MB or smaller
precommit_limit_size(Object) ->
  case erlang:byte_size(riak_object:get_value(Object)) of
    Size when Size > 5242880 -> {fail, "Object is larger than 5MB."};
    _ -> Object
  end.
```

使用 JavaScript 编写的 pre-commit 钩子也要接受一个参数，即用 JSON 编码后的 riak_object。这里用到的 JSON 和 Riak MapReduce 中一样。JavaScript pre-commit 函数可以有三种返回结果：

- JSON 编码的 Riak 对象 -- 除了使用 JSON 格式外，其他的都和 Erlang 函数的第一种返回结果完全一样。在写入数据之前会把对象自动转换成原生格式
- `fail` -- 和 Erlang 函数的第2中返回结果完全一样，会终止写入操作
- `{"fail": Reason}`  -- 这个 JSON Hash 和 Erlang 的第3种返回结果作用一样。`Reason` 必须是 JavaScript 字符串格式

*Javascript Pre-commit 示例*

```javascript
// Makes sure the object has JSON contents
function precommitMustBeJSON(object){
  try {
    Riak.mapValuesJson(object);
    return object;
  } catch(e) {
    return {"fail":"Object is not JSON"};
  }
}
```

### 钩子链

bucket 的 *precommit* 属性默认值是空列表。向这个列表中加入一个或多个 pre-commit 钩子函数后（方法如上），Riak 就会在创建、更新或删除对象时调用钩子。如果钩子终止了操作则会停止运行钩子。

##### 示例

Riak 的 pre-commit 钩子有多种用法。其中一种用法是，在写入数据之前对其进行数据验证。下面的例子使用 Javascript 验证 JSON 对象的句法是否合法。

```javascript
//Sample Object
{
  "user_info": {
    "name": "Mark Phillips",
    "age": "25",
  },
  "session_info": {
    "id": 3254425,
    "items": [29, 37, 34]
  }
}


var PreCommit = {
  validate: function(obj){

    // A delete is a type of put in Riak so check and see what this
    // operation is doing

    if (obj.values[[0]][['metadata']][['X-Riak-Deleted']]){
      return obj;
    }

    // Make sure the data is valid JSON
    try{
       data = JSON.parse(obj.values[[0]].data);
       validateData(data);

    }catch(error){
      return {"fail": "Invalid Object: "+error}
    }
    return obj;
  }
};

function validateData(data){
  // Validates that user_info object is in the data
  // and that name and age aren't empty, finally
  // the session_info items array is checked and validated as
  // being populated

  if(
    data.user_info != null &&
    data.user_info.name != null &&
    data.user_info.age != null &&
    data.session_info.items.length > 0
  ){
    return true;
  }else{
    throw( "Invalid data" );
  }
}
```

## Post-Commit 钩子

### API 和行为表现

post-commit 钩子在数据成功写入会执行。更确切的说，钩子函数会在调用程序把这次写入操作标记为成功之前的一瞬间被 riak_kv_put_fsm 调用。钩子函数必须接受一个参数，即刚写入的 riak_object 实例，任何返回值都会被忽略。和 pre-commit 钩子一样，删除也被认为是一种写入操作，进行删除操作时，post-commit 钩子会检查对象的元数据中是否包含 *X-Riak-Deleted*。执行 post-commit 钩子过程中发生的错误会写入 `sasl-error.log` 日志文件，每行以“problem invoking hook”开头。

##### 示例

```erlang
%% Creates a naive secondary index on the email field of a JSON object
postcommit_index_on_email(Object) ->
    %% Determine the target bucket name
    Bucket = erlang:iolist_to_binary([riak_object:bucket(Object),"_by_email"]),
    %% Decode the JSON body of the object
    {struct, Properties} = mochijson2:decode(riak_object:get_value(Object)),
    %% Extract the email field
    {<<"email">>,Key} = lists:keyfind(<<"email">>,1,Properties),
    %% Create a new object for the target bucket
    %% NOTE: This doesn't handle the case where the
    %%       index object already exists!
    IndexObj = riak_object:new(Bucket, Key,<<>>, %% no object contents
                               dict:from_list(
                                 [
                                  {<<"content-type">>, "text/plain"},
                                  {<<"Links">>,
                                   [
                                    {{riak_object:bucket(Object), riak_object:key(Object)},<<"indexed">>}]}
                                 ])),
    %% Get a riak client
    {ok, C} = riak:local_client(),
    %% Store the object
    C:put(IndexObj).
```

### 钩子链

bucket 的 *postcommit* 属性默认值是空列表。向这个列表中加入一个或多个 post-commit 钩子函数后（方法如上），Riak 就会在创建、更新或删除对象后调用钩子。每个钩子都在单独的进程中运行，所以同一个更新操作可以调用多个钩子，并行执行。_每个创建、更新和删除操作都会执行列表中的所有钩子函数。_
