---
title: Bitcask Capacity Planning
project: riak
version: 1.4.2+
document: appendix
toc: true
keywords: [planning, bitcask]
---

如果你打算使用默认的 [[Bitcask]] 存储方式做后台，可以使用下面的计算器算出集群的大小。

这篇文章的目的是在规划集群时给你一个大概的预估。计算的结果是最佳的预测，有点保守。计算时最好预留一些空间，以备没预想到的增长，这样一旦需求变化就可以在集群中增加更多的节点。

<div id="node_info" class="calc_info"></div>
<div class="calculator">
   <ul>
     <li>
       <label for="n_total_keys">总的键数：</label>
       <input id="n_total_keys"  type="text" size="12" name="n_total_keys" value="" class="calc_input">
       <span class="error_span" id="n_total_keys_error"></span>
     </li>
     <li>
       <label for="n_bucket_size">bucket 的平均大小（字节）：</label>
       <input id="n_bucket_size"type="text" size="7" name="n_bucket_size" value="" class="calc_input">
       <span class="error_span"id="n_bucket_size_error"></span>
     </li>
     <li>
       <label for="n_key_size">键的平均大小（字节）：</label>
       <input type="text" size="2" name="n_key_size" id="n_key_size" value="" class="calc_input">
       <span class="error_span" id="n_key_size_error"></span>
     </li>
     <li>
       <label for="n_record_size">值的平均大小（字节）：</label>
       <input id="n_record_size"type="text" size="7" name="n_record_size" value="" class="calc_input">
       <span class="error_span"id="n_record_size_error"></span>
     </li>
     <li>
       <label for="n_ram">每个节点的 RAM 大小（GB）：</label>
       <input type="text" size="4" name="n_ram" id="n_ram" value="" class="calc_input">
       <span class="error_span" id="n_ram_error"></span>
     </li>
     <li>
       <label for="n_nval"><i>N</i>（副本数量）</label>
       <input type="text" size="2" name="n_nval" id="n_nval" value="" class="calc_input">
       <span class="error_span" id="n_nval_error"></span>
     </li>
</ul>
</div>

### 推荐设置

<span id="recommend"></span>


### Bitcask RAM 大小计算详解

了解上述说明后，下面的因素影响着 RAM 的计算结果：

* *每个键对静态 Bitcask 的开销* - 每个键 22 字节
* *预计的 bucket+key 平均长度* - 即 bucket 名和键名合在一起的字符平均长度。假设一个字符占位一字节
* *预计的对象总数* - 集群中存储的键值对总数
* *副本数（n_val）* - 写入 Riak 时每个键要创建的副本数量，默认为 3

**最终的计算公式是**

Bitcask 所需 RAM 的预计值 = (每个键对静态 Bitcask 的开销 + 预计的 bucket+key 平均长度) * 预计的对象总数 * n_val

例如：

* 集群中有 50,000,000 个键
* 每个 bucket+name 长度大约为 30 字节
* n_val 取默认值 3

Bitcask 所需的 RAM 大约是 **9.78GB**。

Bitcask 还依赖操作系统的文件系统缓存来提供高性能的读取操作。所以在规划集群时要考虑文件系统的缓存，为其预留几 GB 的 RAM。
