<!--
  - Index.vue
  - Copyright (c) 2022 james@firefly-iii.org
  -
  - This file is part of Firefly III (https://github.com/firefly-iii).
  -
  - This program is free software: you can redistribute it and/or modify
  - it under the terms of the GNU Affero General Public License as
  - published by the Free Software Foundation, either version 3 of the
  - License, or (at your option) any later version.
  -
  - This program is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - GNU Affero General Public License for more details.
  -
  - You should have received a copy of the GNU Affero General Public License
  - along with this program.  If not, see <https://www.gnu.org/licenses/>.
  -->

<template>
  <q-page>
    <q-table
      v-model:pagination="pagination"
      :columns="columns"
      :loading="loading"
      :rows="rows"
      :title="$t('firefly.categories')"
      class="q-ma-md"
      row-key="id"
      @request="onRequest"
    >
      <template v-slot:header="props">
        <q-tr :props="props">
          <q-th
            v-for="col in props.cols"
            :key="col.name"
            :props="props"
          >
            {{ col.label }}
          </q-th>
        </q-tr>
      </template>
      <template v-slot:body="props">
        <q-tr :props="props">
          <q-td key="name" :props="props">
            <router-link :to="{ name: 'categories.show', params: {id: props.row.id} }" class="text-primary">
              {{ props.row.name }}
            </router-link>
          </q-td>
          <q-td key="menu" :props="props">
            <q-btn-dropdown color="primary" label="Actions" size="sm">
              <q-list>
                <q-item v-close-popup :to="{name: 'categories.edit', params: {id: props.row.id}}" clickable>
                  <q-item-section>
                    <q-item-label>Edit</q-item-label>
                  </q-item-section>
                </q-item>
                <q-item v-close-popup clickable @click="deleteCategory(props.row.id, props.row.name)">
                  <q-item-section>
                    <q-item-label>Delete</q-item-label>
                  </q-item-section>
                </q-item>
              </q-list>
            </q-btn-dropdown>
          </q-td>
        </q-tr>
      </template>
    </q-table>
    <p>
      <q-btn :to="{name: 'categories.show', params: {id: 0}}">Transactions without a category</q-btn>
    </p>
    <q-page-sticky :offset="[18, 18]" position="bottom-right">
      <q-fab
        color="green"
        direction="up"
        icon="fas fa-chevron-up"
        label="Actions"
        label-position="left"
        square
        vertical-actions-align="right"
      >
        <q-fab-action :to="{ name: 'categories.create'}" color="primary" icon="fas fa-exchange-alt" label="New category"
                      square/>
      </q-fab>
    </q-page-sticky>
  </q-page>
</template>

<script>
// import {mapGetters, useStore} from "vuex";
import Destroy from "../../api/generic/destroy";
import List from "../../api/categories/list";
import {useFireflyIIIStore} from "../../stores/fireflyiii";

export default {
  name: 'Index',
  watch: {
    $route(to) {
      // react to route changes...
      if ('categories.index' === to.name) {
        this.page = 1;
        this.updateBreadcrumbs();
        this.triggerUpdate();
      }
    }
  },
  data() {
    return {
      rows: [],
      pagination: {
        sortBy: 'desc',
        descending: false,
        page: 1,
        rowsPerPage: 5,
        rowsNumber: 100
      },
      loading: false,
      columns: [
        {name: 'name', label: 'Name', field: 'name', align: 'left'},
        {name: 'menu', label: ' ', field: 'menu', align: 'right'},
      ],
      store: null,
    }
  },
  computed: {
    // ...mapGetters('fireflyiii', ['getRange', 'getCacheKey', 'getListPageSize']),
  },
  created() {
    this.pagination.rowsPerPage = this.getListPageSize;
    this.store = useFireflyIIIStore();
  },
  mounted() {
    this.type = this.$route.params.type;
    if (null === this.store.getRange.start || null === this.store.getRange.end) {

      // subscribe, then update:
      this.store.$onAction(
        ({name, $store, args, after, onError,}) => {
          after((result) => {
            if (name === 'setRange') {
              this.range = result;
              this.triggerUpdate();
            }
          })
        }
      )

    }
    if (null !== this.store.getRange.start && null !== this.store.getRange.end) {
      this.range = {start: this.store.getRange.start, end: this.store.getRange.end};
      this.triggerUpdate();
    }
  },
  methods: {
    deleteCategory: function (id, name) {
      this.$q.dialog({
        title: 'Confirm',
        message: 'Do you want to delete category "' + name + '"? Any and all transactions linked to this category will be spared.',
        cancel: true,
        persistent: true
      }).onOk(() => {
        this.destroyCategory(id);
      });
    },
    destroyCategory: function (id) {
      (new Destroy('categories')).destroy(id).then(() => {
        this.store.refreshCacheKey();
        this.triggerUpdate();
      });
    },
    updateBreadcrumbs: function () {
      this.$route.meta.pageTitle = 'firefly.categories';
      this.$route.meta.breadcrumbs = [{title: 'categories'}];

    },
    onRequest: function (props) {
      this.page = props.pagination.page;
      this.triggerUpdate();
    },
    triggerUpdate: function () {
      if (this.loading) {
        return;
      }
      if (null === this.range.start || null === this.range.end) {
        return;
      }
      this.loading = true;
      const list = new List();
      this.rows = [];
      list.list(this.page, this.getCacheKey).then(
        (response) => {
          this.pagination.rowsPerPage = response.data.meta.pagination.per_page;
          this.pagination.rowsNumber = response.data.meta.pagination.total;
          this.pagination.page = this.page;

          for (let i in response.data.data) {
            if (response.data.data.hasOwnProperty(i)) {
              let current = response.data.data[i];
              let account = {
                id: current.id,
                name: current.attributes.name,
              };
              this.rows.push(account);
            }
          }
          this.loading = false;
        }
      )
      ;
    }
  }
}
</script>
