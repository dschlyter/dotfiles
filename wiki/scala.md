# Collections

Traversable -> Iterable -> Seq/Set/Map

* Traversable - has head, tail (removed in 2.13)
* Iterable - java style iteration, may be infinite
* Seq - has ordering (e.g. not set or map)
* IndexedSeq - has access by index 

Immutable by default.

[diagram](https://docs.scala-lang.org/resources/images/tour/collections-immutable-diagram.svg)

## Immutable collections

* List - Linked list, the workhorse of Scala.* Vector - Trie with branching factor 32. Effectively O(1) time random access, append, update, etc. Solid all round choice.
* LazyList - a lazy linked list, can represent infinite collections etc
* Stream - deprecated for LazyList in 2.13, tail is lazy, head is not
* Queue - addLast, popFirst. Amortized O(1) Implemented with two lists, push on one, pop on the other, switch and reverse when pop is empty.* Stack - basically a list, not used much* Range - Equally spaced integers. Head, tail and random access in constant time with calculaton
* String - Array of chars. Full copy on every change so beware.
* HashMap - Trie/Vector backed HashMap. Effectively O(1) time random access, add, update, etc.* ListMap - Dumb map that iterates through a list, O(n) but good if first item is very often selected.
Immutable collections often don't have methods but only operators, and they are confusing and hard to autocomplete

### Element operations

`c :+ e` append element
`e +: c` prepend element 
`c + e` add to set
`c + (e -> v)` update map (also `.updated(e, v)`)
`c - a` remove key a from map or set`c +:= a` and similar work for updating vars
Warning: `List("ok") + "wat"` will result in `"List(ok)wat"`. Javascript style string-conversion.
### Collections operations
`c ++ c2` concat (union for sets and maps, for sets also `|`)
`c -- c2` subtract (only for sets and maps)`c & c2` set intersection

## Mutable collections

ArrayBuffer - Mutable array
ListBuffer - Mutable linked list, O(1) append on tail, optimized for building immutable Lists
MutableList - Mutable linked list, O(1) append on tail, difference https://stackoverflow.com/questions/5446744/difference-between-mutablelist-and-listbuffer/5753935ArraySeq - Mutable but fixed size arrayStack - Mutable stackQueue - Mutable queue
StringBuilder

* [Performance of collections](https://docs.scala-lang.org/overviews/collections/performance-characteristics.html)
* [Offical docs](https://docs.scala-lang.org/overviews/collections/concrete-immutable-collection-classes.html)
* [Blog with implementation details](https://www.waitingforcode.com/scala-collections/collections-complexity-scala-immutable-collections/read)

## Iterator functions

    val l = List(1,2,3,4)
    l.sliding(2).toList = List(List(1, 2), List(2, 3), List(3, 4))
    l.grouped(2).toList = List(List(1, 2), List(3, 4))
    l.span(_ < 2) = (List(1),List(2, 3, 4))
    l.partition(_ % 2 == 0) = (List(2, 4),List(1, 3))
    l.take(3) = List(1, 2, 3)
    l.takeRight(3) = List(2, 3, 4)
    l.drop(3) = List(4)
    l.last = 4
    l.lastOption = Some(4)
    l.sum = 10
    l.reduce((a,b) => a+b) = 10

## Conversions

    l.toList l.toSet l.toSeq l.toIndexedSeq l.toStream 
    tuples.toMap

# Equality

`==` is java equals and `eq` is java ==

    val n = 12345689
    n.toString == n.toString = true
    n.toString eq n.toString = false

# Emptiness

    null - like java
    Null - a trait whoose only instance is null, bottom type for AnyRef
    Nothing - bottom type for Any, has no instances
    Unit - void in java
    Nil - same as List(), terminates a list, Nil.map(...) == Nil
    None - option empty type

# Functions

## Partial application

    val add2 = add(2, _:Int)

## Methods and functions

    def method(a: Int) = a + 1
    val function = (a: Int) => a + 1

Methods always belong to an object, and are evaluated automagically when referred (aka Uniform access principle, however this is deprecated and dropped in Scala 3 if the method is defined like `method()` instead of `method`. In Scala 3 calling `method()` as `method` will convert it to a function).

Under the hood methods are JVM methods (better performance), while functions are objects with an apply() method.

Turn a method into a function with partial application.

    list.length # => 3
    list.length _ # => () => Int

Methods can also get type parameters, but functions cannot.

Methods with type params converted into methods will get impossible types.

    def tripple[A](elem: A) = List.fill(3)(elem)
    tripple(6) // returns: List[Int](6, 6, 6)
    val f = tripple _ 
    f(6) // error: type mismatch; found: Int(6) required: Nothing

Functions are values, and can't take arguments by-name, can't be polymorphic, can't be variadic, can't be overloaded, and can't have implicit parameters. While methods can have these, they cannot be passed around as values.

## Partial functions

    val f: PartialFunction[Int, String] = { case 1 => "one" }
    val g: PartialFunction[Int, String] = { case _ => "not one" }
    (f orElse g)(2)

Note: Partial definition and partial application (see above) should not be confused.

## Varargs

    def func(x: Int, y: String, z: String*)

Unpacking a list to varargs

    func(1, "two", List(3,4,5,6): _*)

## Composition

    (f andThen g) g(f(x))
    (f compose g) f(g(x))    

## Multi param lists 

Note: This is not the same as currying (functions returning functions), even if many resources call this currying.

    def multiply(m: Int)(n: Int): Int = m * n
    val f = multiply(5)(_)
    f(6)

Advantage is that one group can be used for type inference of the next one. (lol java can do this without currying, worse typing than java, wat?)

neophytes guide recommends using this for dependency injection
    
    getMessages(db: DB)(username: String)

Also required for implicits.

## Byname parameter

Because why keep things simple. `() => Int`, `=> Int` and `Int` are different.
    
    def calc1(x: () => Int) = x()
    def calc2(x: => Int) = x
    def calc3(x: Int) = x
    calc1 {() => 42} // explicit lambda required
    calc2 {42} // explicit lambda not required and also not allowed
    calc3 {42} // also works, block is executed before call

# Pattern matching

    x match {
        case 1 => "one"
        case _ => "many"
    }

Use @ to match both full value and break down

    case list @ List(x,y,z) => ...

Create your own with extractors. This works as a reverse constructor, creating a tuple out of your object.

    object FreeUser {
        def unapply(user: FreeUser): Option[(String, Int, Double)]
    }

You can create custom extractors on new objects. These can be used for boolean matches (only match some objects) and to pattern match infix operators like 1 :: 2.

Use `unapplySeq` to unapply to a variable length seq, like `case List(a,b,c,d,e)`

Pattern matching can also be used in for statements and even assignments (but this seems type unsafe?)

    val List(x,y,z) = List(1,2,3)

You can also unapply into brand new types if there is a proper unapply method. You can have as many unapply methods as you want, and they can exist both on instances and on static companion objects.

    val Values(a,b) = Map(a -> 1, b -> 2)

## Matching against variables

Is dangerous and tricky.

    val x = 1
    2 match {
      case x => println("1")
      case _ => println("default match")
    }

x will match against anything, it will be a new variable shadowing the declared x. Use \`x\` to refer to the variable without declaring a new one.

# For expressions

    val result = for {
      numList <- nums
      num <- numList
      if (num % 2 == 0)
    } yield (num)

This is also good for dealing with options (instead of chaining maps)

# Handling failure

You have Either and Try (newer)

Try supports map, flatMap and for comprehensions. Either has right/left projections with map which are similar but more ugly, and can cause some type confusion.

Either has more specific error types (Try has throwables) so it can be used for expected errors, or errors that should not abort execution.

# Async

Futures and for comprehensions work well together. (almost makes up for the lack of async/await keywords)

    for {
      heatedWater <- heatWater(Water(25))
      okay <- temperatureOkay(heatedWater)
    } yield okay

However for-comprehensions are evaluated sequentially, so make sure to instantiate your futures outside if parallellism is needed.

# Types
    
* Parametric polymorphism (aka generics)
* Type inference (aka var, val)
* Scala has covariance and contravariance to allow inheritance between Container[T] and Container[T'] (declaration-side variance)
* Type bounds with T <: Animal (use-side variance like java <T extends Animal>)
* Viewable type bounds A <% Int (if you don't need to modify the object, aka there is a implicit conversion function) - this is deprecated in favor of implicit parameters
* Scala provides Manifests as an implicit value to recover type information

Polymorphism is rank 1 and type inference is local, so much less generic than e.g. Haskell.

## Case classes

Case classes automatically get immutability, equality/hash and pattern matching.

## Type classes

A type class requires some behaviour to be implemented for every type in its class.

    trait NumberLike[T] { ... }

    implicit object NumberLikeDouble extends NumberLike[Double] { ... }

    def mean[T](xs: Vector[T])(implicit ev: NumberLike[T]): T

The user can define new implementations if there are none available.

A common use case is serialization.

## Traits with Self types

Declare a dependency that is mandatory to specify at initialisation time.

    trait A { self: B =>
      def aId = 1
    }

    val obj = new A with B

## Type aliases

Are not new types.

Can be used for functions.

    type SocketFactory = SocketAddress => Socket

Can also be used to simplify type signatures or make all imports from one place.

## Path dependent types

A nested type in scala is bound to the specific instance of the outer type.

    class Animal { class Food { ... } }
    var x = cat.Food
    var y = dog.Food
    y = x // does not work since these are different types

You can refer to any of these types with

    val z: Animal#Food = x

## Abstract types

Types can be undeclared and decided by a subclass.

    abstract class Animal(name: String) { type SuitableFood }
    trait EatsGrass extends Animal { type SuitableFood = Grass }
    class cow extends Animal with EatsGrass

There seems to be a big overlap with generics here. (parameterization vs abstract members)
The argument seems to be that this approach handles multiple abstract types a lot better.

Oderskys argument

> There have always been two notions of abstraction: parameterization and abstract members. In Java you also have both, but it depends on what you are abstracting over. In Java you have abstract methods, but you can't pass a method as a parameter. You don't have abstract fields, but you can pass a value as a parameter. And similarly you don't have abstract type members, but you can specify a type as a parameter. So in Java you also have all three of these, but there's a distinction about what abstraction principle you can use for what kinds of things. And you could argue that this distinction is fairly arbitrary. 

A (over?)simplification would be that generics model `of` relationships while abstract types model `has a` relationships.

## Structural typing

    def foo(x: { def get: Int }) = 123 + x.get

Implementation uses reflection, so be performance-aware!

## Implicits

    def min[B >: A](implicit cmp: Ordering[B]) { ... }

You can pass in your own orderings.

Access implicits with `implicitly`

    scala> implicitly[Ordering[Int]]
    res37: Ordering[Int] = scala.math.Ordering$Int$@3a9291cf

Use @implicitNotFound annotation to give better errors if you define your own implicit types

The actual arguments that are eligible to be passed to an implicit parameter fall into two categories:

* First, eligible are all identifiers x that can be accessed at the point of the method call without a prefix and that denote an implicit definition or an implicit parameter. That is you defined variables and imports.
* Second, eligible are also all members of companion modules of the implicit parameter's type that are labeled implicit.

### Implicit type evidence

Implement a trait that is not implemented on a class you don't own.

    case class Bar(value: String)
    trait WithFoo[A] { def foo(x: A): String }
    implicit object MakeItFoo extends WithFoo[Bar] { def foo(x: Bar) = x.value }
    def callFoo[A](thing: A)(implicit evidence: WithFoo[A]) = evidence.foo(thing)
    callFoo(Bar("hi"))

### Implement methods on type you don't own

Implement an implicit class and make sure it is imported.

    object StringUtils {
        implicit class StringImprovements(s: String) {
            def increment = s.map(c => (c + 1).toChar)
        }
    }

Or for a generic type but only for some values.

    implicit class ListStringImprovements(s: List[Int]) {
        def increment = s.map(n => n+1)
    }

# Infix and postfix

Any method which takes a single parameter can be used as an infix operator: `a.m(b)` can also be written as `a m b`.

Any method which does not require a parameter can be used as a postfix operator: `a.m` can be written as `a m`.

You can also do type operations infix (why would anyone do this?)

    new (String HashMap String) == new HashMap[String, String]

# Minor notes

* Constructors are just the code outside methods in your class
* There are both abstract classes and traits
* Options are like at-most-one element collections and have map, filter, flatMap, for comprehensions
* To create an enumeration, create an object that extends the abstract class Enumeration. But this might use reflection so be careful about perf.
* Scala will gain optional python-style significant indentation in Scala 3 for classes, methods, for, if and some more

# Cats library

Semigroup - for a type A has a associative combine operation (A,A) -> A.
Monoid - semigroup with empty() base element. allows for reduce/fold operations
Functor - a type class with one "hole" and a operation map[A](op: A -> B): F[B]
Apply - extends Functor with ap[A](op: F[A -> B]): F[B]
Applicative - extends Apply with pure[A](x: A): F[A], e.g. Some(1), List("a")
Monad - extends Applicative with flatten F[F[A]] -> F[A]
Foldable - has a bunch of fold methods
Traverse - transform List[Option[String]] --> Option[List[String]]
Identity - A monad that encodes the effect of no effect. flatMap(f) is just f(x)
Validated - Accumulates errors (instead of aborting on error like Either)
Eval - can be used for lazy and defered evaluation

Semigroups are defined in cats for many Scala types (Int, Lists, Options, etc). They can also merge nested types, e.g. Map[Int,List[Int]].

    Map("foo" -> List(1,2)).combine(Map("foo" -> List(3,4)) == Map("foo" -> List(1,2,3,4))
    Map("foo" -> 100).combine(Map("foo" -> 20) == Map("foo" -> 120)
    Option(1).combine(Option(2)).combine(None) == Option(3)

Functors and Applicatives compose

    val listOpt = Functor[List] compose Functor[Option]
    listOpt.map(List(Some(1), None, Some(3)))(_ + 1) == List(Some(2), None, Some(4))

Two monads cannot automatically compose, but you can defined a monad transform that defines how one specific monad will nest within any other monad. Intuition (maybe wrong), you must always specify how to pack and unpack the monad?

# Scalatest

Default case class diff is not good, here is a big hack for it. There is also libs like diffx.

    def diffFields(a: AnyRef, b: AnyRef, prefix: String = ""): Unit = {
        val fields = a.getClass.getDeclaredFields
        var goodFields: Vector[String] = Vector()
        fields.foreach { f =>
            f.setAccessible(true)
            val av = f.get(a)
            val bv = f.get(b)
            val fieldName = prefix + f.getName
            av == bv match {
                case true => goodFields = goodFields :+ fieldName
                case false =>
                    println("Diffing field " + fieldName)
                    println(av)
                    println(bv)
                    if (av.isInstanceOf[scala.Product] && av != None && bv != None) {
                        diffFields(av, bv, fieldName + ".")
                    }
            }
        }
        println("These fields matched: " + String.join(" ", goodFields: _*))
    }

## Other libs

Scalaz - more scientific in depth complete typing
Algebird - focus on big data pipelines, uses algebra lib and cats-kernel

# Exercises

[Scala exercises](https://www.scala-exercises.org/) are good!
