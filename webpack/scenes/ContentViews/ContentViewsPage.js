import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { useSelector } from 'react-redux';
import { Grid, GridItem, TextContent, Text, TextVariants } from '@patternfly/react-core';
import { selectContentViews,
  selectContentViewStatus,
  selectContentViewError } from './ContentViewSelectors';
import ContentViewsTable from './Table/ContentViewsTable';

const ContentViewsPage = () => {
  const response = useSelector(selectContentViews);
  const status = useSelector(selectContentViewStatus);
  const error = useSelector(selectContentViewError);

  return (
    <Grid className="grid-with-margin">
      <GridItem span={12}>
        <TextContent>
          <Text component={TextVariants.h1}>{__('Content Views')}</Text>
        </TextContent>
      </GridItem>
      <GridItem span={12}>
        <ContentViewsTable {...{ response, status, error }} />
      </GridItem>
    </Grid>
  );
};

export default ContentViewsPage;
