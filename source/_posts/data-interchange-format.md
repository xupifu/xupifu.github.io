---
title: 数据交换 - XML, JSON, ProtoBuf
date: 2017-03-20 19:25:55
tags:
categories: misc
---

本文将罗列几种常见的数据交换方式，数据交换常用于平台或语言无关化的接口调用，配置文件，数据存储等场景。数据交换的方式主要包括XML，JSON，YAML，Protobuf等。

<!--more-->

原创文章版权归原作者所有，商业转载请联系原作者获取授权，任何转载请注明来源：<https://xupifu.github.io/2017/03/20/data-interchange-format/>

## 1 概要

- **HTML**：是一种基于标签（TAG）的数据格式，但领域特定，是Web服务器和客户端浏览器之间的一种交互手段，很难用在其他应用中。
- **XML**：同样是基于TAG的数据格式，很长一段时间以来，作为行业标准，在诸多领域应用广泛，如RPC远程调用，序列化，配置文件，UI模板定义等，其自解释能力非常强，但同时也意味着冗余信息较多，对于需要高性能交互的应用，过多的冗余信息则成了缺点。
- **JSON**：基于Name-Value（也称为Key-Value）的数据交换格式，在保持可读性的同时，较大程度减少了冗余信息。JSON原生自Javascript，由于规则简单，非常便于各种编程语言的解析和生成。近些年，在很多领域已经逐渐取代XML，成为了新的数据交换的标准。同时，一些新的技术领域，则直接基于JSON实现，比如一些NoSQL数据库的实现（**MongoDB**等），**RESTful**接口标准等。不过，该数据交换格式不支持注释，可读性有时不如XML。
- **YAML**：与JSON类似，采用缩进格式，它进一步减少了冗余信息。不过，由于兼容性问题，目前使用领域还比较有限。
- **Protobuf**：是目前冗余信息最少的一种格式，需要专门工具进行生成和解析，生成的内容不具备可读性，但其高性能的优势，使得该数据格式成为了一些特定领域的理想选择。

## 2 数据交换格式

### 2.1 HTML

HTML：超文本标记语言（HyperText Markup Language）是一种用于描述和创建网页的标准标记语言。HTML运行在浏览器上，由浏览器来解析。

```
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <script src="js/jquery-3.1.1.min.js"></script>
</head>
<body>

<h1>Head</h1>

</body>
</html>
```

### 2.2 XML

XML：可扩展标记语言（eXtensible Markup Language），被设计用来传输和存储数据。在大多数Web应用程序中，XML用于传输数据，而HTML用于格式化并显示数据。但XML不仅仅用于Web应用，由于XML能有效地表示结构化数据，使得XML已经成为计算机软件领域数据交换的标准技术模式之一。通过XML实现数据的标准化、结构化，解决了在不同平台、不同系统之间的数据结构/模式的差异，使得数据层在XML技术的支持下统一起来。

XML实例（来自维基百科）

```
<person>
  <firstName>John</firstName>
  <lastName>Smith</lastName>
  <age>25</age>
  <address>
    <streetAddress>21 2nd Street</streetAddress>
    <city>New York</city>
    <state>NY</state>
    <postalCode>10021</postalCode>
  </address>
  <phoneNumbers>
    <phoneNumber>
      <type>home</type>
      <number>212 555-1234</number>
    </phoneNumber>
    <phoneNumber>
      <type>fax</type>
      <number>646 555-4567</number>
    </phoneNumber>
  </phoneNumbers>
  <gender>
    <type>male</type>
  </gender>
</person>
```

XML：使用attribute代替tag（来自维基百科）

```
<person firstName="John" lastName="Smith" age="25">
  <address streetAddress="21 2nd Street" city="New York" state="NY" postalCode="10021" />
  <phoneNumbers>
    <phoneNumber type="home" number="212 555-1234"/>
    <phoneNumber type="fax" number="646 555-4567"/>
  </phoneNumbers>
  <gender type="male"/>
</person>
```

### 2.3 JSON

JSON(JavaScript Object Notation)是一种轻量级的数据交换格式。易于人阅读和编写。同时也易于机器解析和生成。它基于[JavaScript Programming Language](http://www.crockford.com/javascript), [Standard ECMA-262 3rd Edition - December 1999](http://www.ecma-international.org/publications/files/ecma-st/ECMA-262.pdf)的一个子集。JSON采用完全独立于语言的文本格式，但是也使用了类似于C语言家族的习惯（包括C, C++, C#, Java, JavaScript, Perl, Python等）。这些特性使JSON成为理想的数据交换语言。

JSON建构于两种结构：

- "名称/值"对的集合（A collection of name/value pairs）。不同的语言中，它被理解为对象（object），纪录（record），结构（struct），字典（dictionary），哈希表（hash table），有键列表（keyed list），或者关联数组（associative array）。
- 值的有序列表（An ordered list of values）。在大部分语言中，它被理解为数组（array）。

>【[蚍蜉](https://xupifu.github.io)】注：以上说明来自官网：http://www.json.org/json-zh.html

其中，值的基础类型一般为字符串（String），数值（Number），布尔值（Boolean）等。

JSON规则相对简单：

- **单一映射**用":"分隔，即"名称/值"对
- **并列的映射/数据**用","分隔
- **有序列表**用"[]"表示
- **映射集合**用"{}"表示

理论上，所有的数据结构均可以使用该规则进行定义。

JSON实例（来自维基百科）

```
{
  "firstName": "John",
  "lastName": "Smith",
  "age": 25,
  "address": {
    "streetAddress": "21 2nd Street",
    "city": "New York",
    "state": "NY",
    "postalCode": "10021"
  },
  "phoneNumber": [
    {
      "type": "home",
      "number": "212 555-1234"
    },
    {
      "type": "fax",
      "number": "646 555-4567"
    }
  ],
  "gender": {
    "type": "male"
  }
}
```

### 2.4 YAML

YAML：YAML Ain't Markup Language，采用缩进方式，是一种人们可以轻松阅读的数据序列化格式，并且非常适合对动态编程语言中使用的数据类型进行编码，可以用作数据序列化，配置文件，log文件，Internet信息和过滤等。不过，由于标准化带来的兼容性问题，不同语言间的数据交换不建议使用YAML。

YAML实例（来自维基百科）

```
---
firstName: John
lastName: Smith
age: 25
address: 
  streetAddress: 21 2nd Street
  city: New York
  state: NY
  postalCode: '10021'
phoneNumber: 
- type: home
  number: 212 555-1234
- type: fax
  number: 646 555-4567
gender: 
  type: male
```

### 2.5 Protobuf

Protobuf：Google Protocol Buffer是Google公司内部的混合语言数据标准，Protocol Buffers是一种轻便高效的结构化数据存储格式，可以用于结构化数据序列化。它很适合做数据存储或RPC数据交换格式。可用于通讯协议、数据存储等领域的语言无关、平台无关、可扩展的序列化结构数据格式。

ProtoBuf实例

```
package lm; 
message helloworld 
{ 
  required int32  id  = 1;
  required string str = 2;
  optional int32  opt = 3;
}
```

## 附录

1. [维基百科：XML](https://en.wikipedia.org/wiki/XML)
2. [维基百科：JSON](https://en.wikipedia.org/wiki/JSON)
3. [JSON介绍](http://www.json.org/json-zh.html)
4. [ProtoBuf介绍](http://www.ibm.com/developerworks/cn/linux/l-cn-gpb/index.html)


