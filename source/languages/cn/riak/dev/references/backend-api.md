---
title: 后台 API
project: riak
version: 1.4.2+
document: appendix
toc: true
keywords: [api, backends]
---

Riak 存储 API 可用于全部[[支持的后台|选择后台]]。本页[以 Erlang 类型规格表](http://www.erlang.org/doc/reference_manual/typespec.html)的形式列出了存储后台 API 的详细信息。

规格表用于 [dialyzer](http://www.erlang.org/doc/man/dialyzer.html)，Erlang 的静态分析工具。建议把这份规格表复制到任何一个自定义的后台模块中，作为开发时的参考，避免出现错误，也能确保完全能和 Riak 兼容。

下面还列出了函数导出列表，可以直接粘贴到自定义存储后台模块中。

```erlang
%% Riak Storage Backend API
-export([api_version/0,
         start/2,
         stop/1,
         get/3,
         put/5,
         delete/4,
         drop/1,
         fold_buckets/4,
         fold_keys/4,
         fold_objects/4,
         is_empty/1,
         status/1,
         callback/3]).

%% ===================================================================
%% Public API
%% ===================================================================

%% @doc Return the major version of the
%% current API and a capabilities list.
%% The current valid capabilities are async_fold
%% and indexes.
-spec api_version() -> {integer(), [atom()]}.

%% @doc Start the backend
-spec start(integer(), config()) -> {ok, state()} | {error, term()}.

%% @doc Stop the backend
-spec stop(state()) -> ok.

%% @doc Retrieve an object from the backend
-spec get(riak_object:bucket(), riak_object:key(), state()) ->
                 {ok, any(), state()} |
                 {ok, not_found, state()} |
                 {error, term(), state()}.

%% @doc Insert an object into the backend.
-type index_spec() :: {add, Index, SecondaryKey} | {remove, Index, SecondaryKey}.
-spec put(riak_object:bucket(), riak_object:key(), [index_spec()], binary(), state()) ->
                 {ok, state()} |
                 {error, term(), state()}.

%% @doc Delete an object from the backend
-spec delete(riak_object:bucket(), riak_object:key(), [index_spec()], state()) ->
                    {ok, state()} |
                    {error, term(), state()}.

%% @doc Fold over all the buckets
-spec fold_buckets(riak_kv_backend:fold_buckets_fun(),
                   any(),
                   [],
                   state()) -> {ok, any()} | {async, fun()}.

%% @doc Fold over all the keys for one or all buckets.
-spec fold_keys(riak_kv_backend:fold_keys_fun(),
                any(),
                [{atom(), term()}],
                state()) -> {ok, term()} | {async, fun()}.

%% @doc Fold over all the objects for one or all buckets.
-spec fold_objects(riak_kv_backend:fold_objects_fun(),
                   any(),
                   [{atom(), term()}],
                   state()) -> {ok, any()} | {async, fun()}.

%% @doc Delete all objects from this backend
%% and return a fresh reference.
-spec drop(state()) -> {ok, state()} | {error, term(), state()}.

%% @doc Returns true if this backend contains any
%% non-tombstone values; otherwise returns false.
-spec is_empty(state()) -> boolean() | {error, term()}.

%% @doc Get the status information for this backend
-spec status(state()) -> [{atom(), term()}].

%% @doc Register an asynchronous callback
-spec callback(reference(), any(), state()) -> {ok, state()}.
```
