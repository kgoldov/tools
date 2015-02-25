class DebugModelResource(ModelResource):

    def alter_deserialized_detail_data(self, request, data):
        data['anonymous'] = False
        return super(ObservationResource, self).alter_deserialized_detail_data(request, data)

    def hydrate(self, bundle):
        bundle = super(ObservationResource, self).hydrate(bundle)
        return bundle

    def full_hydrate(self, bundle):
        bundle = super(ObservationResource, self).full_hydrate(bundle)
        return bundle

    def hydrate_FOO(self, bundle):
        return bundle
