toKeyVal = (attributes, separator = ' ')->
    ("#{key} = \"#{val}\"" for key, val of attributes)
        .join separator

if angular.mock
    window.render = angular.mock.render =
    (directive, data = {}, attributes = {}, transclude = "")->
        $element = null
        inject ($compile, $rootScope)->
            $scope = $rootScope.$new()
            $scope[key] = val for key, val of data
            attributes = toKeyVal attributes

            template = $compile(
                "<div #{directive} #{attributes}>#{transclude}</div>"
            )
            $element = template($scope.$new())

            $element.$scope = $scope

            try
                $scope.$digest()
            catch exception
                console.error "Exception when rendering #{directive}", exception
                throw exception
        $element
