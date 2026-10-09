/// Intimhigiéniai termékek, ajánlott cserélési idővel.
/// Az időtartamok általános iránymutatások, a termék leírása az irányadó.
enum HygieneProduct {
  pad(Duration(hours: 4)),
  reusablePad(Duration(hours: 5)),
  periodUnderwear(Duration(hours: 10)),
  tampon(Duration(hours: 4)),
  cup(Duration(hours: 8)),
  disc(Duration(hours: 8));

  const HygieneProduct(this.defaultDuration);
  final Duration defaultDuration;
}
