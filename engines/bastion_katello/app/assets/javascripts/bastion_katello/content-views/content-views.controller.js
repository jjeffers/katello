/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewsController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires ContentView
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewsController',
    ['$scope', 'Nutupane', 'ContentView', 'CurrentOrganization', 'RepositoryTypesService',
    function ($scope, Nutupane, ContentView, CurrentOrganization, RepositoryTypesService) {

        var nutupane = new Nutupane(ContentView, {
            'nondefault': true,
            'organization_id': CurrentOrganization,
            'sort_by': 'name',
            'sort_order': 'ASC'
        });
        nutupane.primaryOnly = true;
        $scope.controllerName = 'katello_content_views';

        $scope.table = nutupane.table;

        $scope.importOnlyEnabled = function() {
            return RepositoryTypesService.pulp3Supported('yum');
        };
    }]
);
