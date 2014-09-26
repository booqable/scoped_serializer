# ScopedSerializer

## What does it do?

ScopedSerializer serializes your models based on context;

```ruby
class OrderSerializer < ScopedSerializer::Serializer
  attributes :id, :status
  has_one :customer

  scope :resource do
    has_many :products => :stock_items
  end
end

# ScopedSerializer.render(@order) # Default output
# ScopedSerializer.render(@order, :resource) # Includes products and stock_items
```

It supports associations and eager loading out-of-the-box.

## The problem

While developing the API for Booqable, we ran into problems where we would return different data based on context. For example we would list orders but not nested associations. When the user requests a single order, we do want to render nested associations. This resulted in overly complicated serializers with a lot of conditional rendering.

The alternative would be to create different serializer based on context, such as `OrderCollectionSerializer` and `OrderResourceSerializer`.

## The solution

Using ScopedSerializer you can create one serializer with different configuration based on scope.

### Example

```ruby
class OrderSerializer < ScopedSerializer::Serializer
  attributes :id, :status
  has_one :customer

  scope :resource do
    has_many :products => :stock_items
  end
end
```

The above example will render the following outputs:

__Example for `ScopedSerializer.render(@order)`__
```json
{
  order: {
    id: 1,
    status: 'reserved',
    customer: { ... }
  }
}
```

__Example for `ScopedSerializer.render(@order, :resource)`__
```json
{
  order: {
    id: 1,
    status: 'reserved',
    customer: { ... },
    products: [
      {
        id: 1,
        name: 'Sony NX5',
        stock_items: [...]
      }
    ]
  }
}
```

## Scopes

Scopes are not pre-defined and thus can be anything you want. Whatever you need. In our application we render the scope `:collection` for index actions and `:resource` for resource actions. This entirely depends on your implementation. If a scope does not exist it will simply use the default settings.

## Associations

All associations are supported;

- has_many
- has_one (or belongs_to if you prefer it)

ScopedSerializer takes care of eager loading associations. Need custom eager loading? No problem, just override it.

```ruby
class OrderSerializer < ScopedSerializer::Serializer
  scope :resource do
    has_many :products => :stock_items, :preload => false
  end
  scope :something_else do
    has_many :products => :stock_items, :preload => { :stock_items => :item }
  end
end
```

ScopedSerializer __does not eager load collections__. You will need to manually eager load the nested associations. For example:

```ruby
# No eager loading at all
ScopedSerializer.render(Order.all, :resource)
# Manually eager load
ScopedSerializer.render(Order.includes(:products => :stock_items), :resource)
```

__More options__

```ruby
class OrderSerializer < ScopedSerializer::Serializer
  scope :resource do
    # Render a specific scope
    has_many :products => :stock_items, :scope => :resource

    # Render a specific serializer
    has_many :products => :stock_items, :serializer => ItemSerializer
  end
end
```

## Contributing

- Fork it
- Create your feature branch (git checkout -b my-new-feature)
- Commit your changes (git commit -am 'Add some feature')
- Push to the branch (git push origin my-new-feature)
- Create a new Pull Request
