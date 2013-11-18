---
title: Key Filters Reference
project: riak
version: 1.4.2+
document: tutorials
toc: true
audience: beginner
keywords: [developers, mapreduce, keyfilters]
---

## 转换函数

键过滤器的转换函数对键进行处理，把键转换成能被[[判定函数|Using Key Filters#Predicate-functions]]测试的格式。转换过滤器的描述信息后都跟着使用 JSON 编写的示例用法。

如果在 Erlang 中使用，函数名（和键）都使用二进制形式。

### `int_to_string`

把整数（通过 `string_to_int` 提取得到）转换成字符串。

```javascript
[["int_to_string"]]
```

### `string_to_int`

把字符转转换成整数。

```javascript
[["string_to_int"]]
```

### `float_to_string`

把浮点数（通过 `string_to_float` 提取得到）转换成字符串。

```javascript
[["float_to_string"]]
```

### `string_to_float`

把字符串转换成浮点数。

```javascript
[["string_to_float"]]
```

### `to_upper`

把所有字母都转换成大写。

```javascript
[["to_upper"]]
```

### `to_lower`

把所有字母都转换成小写。

```javascript
[["to_lower"]]
```

### `tokenize`

拆分第一个参数中指定的字符串，返回第二个参数中指定的第 N 个记号。

```javascript
[["tokenize", "/", 4]]
```

### `urldecode`

解码 URL 字符串。

```javascript
[["urldecode"]]
```

## 判断函数

键过滤器的判定函数在输入数据上进行测试，返回 `true` 或 `false`。所以判定函数应该是一系列键过滤器中的最后一个，而且经常放在[[转换函数|Using Key Filters#Transform-functions]]之后。

<div class="note">
	<div class="title">比较型判定函数</div>
	`greater_than`、`less_than_eq` 和 `between` 这种判定函数按照 Erlang 的比较方式进行比较，也就是说数字就按照值本身进行比较（可以进行适当的强制类型转换），字符串按照字面值进行比较。
</div>

### `greater_than`

测试输入值是否大于参数指定的值。

```javascript
[["greater_than", 50]]
```

### `less_than`

测试输入值是否小于参数指定的值。

```javascript
[["less_than", 10]]
```

### `greater_than_eq`

测试输入值是否大于或等于参数指定的值。

```javascript
[["greater_than_eq", 2000]]
```

### `less_than_eq`

测试输入值是否小于或等于参数指定的值。

```javascript
[["less_than_eq", -2]]
```

### `between`

测试输入值是否在前两个参数指定的值之间。如果有第 3 个参数，指定范围是否包含边界的值。如果没有第 3 个值，则包含边界值。

```javascript
[["between", 10, 20, false]]
```

### `matches`

测试输入值是否匹配参数指定的正则表达式。

```javascript
[["matches", "solutions"]]
```

### `neq`

测试输入值是否不等于参数指定的值。

```javascript
[["neq", "foo"]]
```

### `eq`

测试输入值是否等于参数指定的值。

```javascript
[["eq", "basho"]]
```

### `set_member`

测试输入值是否在参数指定的一系列值中。

```javascript
[["set_member", "basho", "google", "yahoo"]]
```

### `similar_to`

测试输入值到第一个参数的 [[Levenshtein 距离|http://en.wikipedia.org/wiki/Levenshtein_distance]]是否在第二个参数指定的次数之内。

```javascript
[["similar_to", "newyork", 3]]
```

### `starts_with`

测试输入值是否以参数指定的字符串开头。

```javascript
[["starts_with", "closed"]]
```

### `ends_with`

测试输入值是否以参数指定的字符串结尾。

```javascript
[["ends_with", "0603"]]
```

### `and`

对多个键过滤器操作进行逻辑 AND 操作。

```javascript
[["and", [["ends_with", "0603"]], [["starts_with", "basho"]]]]
```

### `or`

对多个键过滤器操作进行逻辑 OR 操作。

```javascript
[["or", [["eq", "google"]], [["less_than", "g"]]]]
```

### `not`

取反键过滤器操作的结果。

```javascript
[["not", [["matches", "solution"]]]]
```
