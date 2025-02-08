extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}



// Stream<List<T>> filterFunction(bool Function(T)  user)=>map((users) => users.where(user).toList());