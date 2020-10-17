public class Cake
{
  private readonly ISprinkles _sprinkles;
  private readonly IFrosting _frosting;

  public Cake(ISprinkles sprinkles, IFrosting frosting)
    => (_sprinkles, _frosting) = (sprinkles, frosting);
}