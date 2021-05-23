#ifndef STC_HPP
#define STC_HPP

namespace stc {

struct _Params {};
struct Itself {};

template <class Exact>
class Any {};

template <typename Exact>
Exact& exact(Any<Exact>& ref) {
    return *(Exact*)(void*)(&ref);
}

template <typename Exact>
const Exact& exact(const Any<Exact>& cref) {
    return *(const Exact*)(const void*)(&cref);
}

template <typename Exact>
Exact* exact(Any<Exact>* ptr) {
    return (Exact*)(void*)(ptr);
}

template <typename Exact>
const Exact* exact(const Any<Exact>* cptr) {
    return (const Exact*)(const void*)(cptr);
}

// default version
template <class T, class Exact>
struct FindExact { typedef Exact ret; };
// version specialized for Exact=Itself
template <class T>
struct FindExact<T, Itself> { typedef T ret; };

} // namespace stc

#define STC_FIND_EXACT(Type) typename stc::FindExact<Type<Exact>, Exact>::ret

// eq. class Class
#define STC_CLASS(Class) template<typename Exact = stc::Itself> class Class : public stc::Any<Exact>

// eq. class Class1 : public Parent
#define STC_CLASS_D(Class, Parent)                   \
  template <typename Exact = stc::Itself>            \
  class Class : public Parent<STC_FIND_EXACT(Class)>

// return the parent class (eq. Class2)
#define STC_PARENT(Class, Parent) Parent<STC_FIND_EXACT(Class)>

#endif
