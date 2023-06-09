<!--
  - Edit.vue
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
    <div class="row q-mx-md">
      <div class="col-12">
        <q-banner v-if="'' !== errorMessage" class="bg-orange text-white" inline-actions rounded>
          {{ errorMessage }}
          <template v-slot:action>
            <q-btn flat label="Dismiss" @click="dismissBanner"/>
          </template>
        </q-banner>
      </div>
    </div>
    <div class="row q-mx-md q-mt-md">
      <div class="col-12">
        <q-card bordered>
          <q-card-section>
            <div class="text-h6">Edit rule group</div>
          </q-card-section>
          <q-card-section>
            <div class="row">
              <div class="col-12 q-mb-xs">
                <q-input
                  v-model="title"
                  :disable="disabledInput"
                  :error="hasSubmissionErrors.title" :error-message="submissionErrors.title" :label="$t('form.title')" bottom-slots clearable outlined
                  type="text"/>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <div class="row q-mx-md">
      <div class="col-12">
        <q-card class="q-mt-xs">
          <q-card-section>
            <div class="row">
              <div class="col-12 text-right">
                <q-btn :disable="disabledInput" color="primary" label="Update" @click="submitRuleGroup"/>
              </div>
            </div>
            <div class="row">
              <div class="col-12 text-right">
                <q-checkbox v-model="doReturnHere" :disable="disabledInput" label="Return here" left-label/>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>

  </q-page>
</template>

<script>
import Get from "../../api/rule-groups/get";
import Put from "../../api/rule-groups/put";
import {useFireflyIIIStore} from "../../stores/fireflyiii";

export default {
  name: "Edit",
  data() {
    return {
      submissionErrors: {},
      hasSubmissionErrors: {},
      submitting: false,
      doReturnHere: false,
      doResetForm: false,
      errorMessage: '',

      // rule group fields:
      id: 0,
      title: '',
      store: null,
    }
  },
  computed: {
    disabledInput: function () {
      return this.submitting;
    }
  },
  created() {
    this.id = parseInt(this.$route.params.id);
    this.store = useFireflyIIIStore();
    this.collectRuleGroup();
  },
  methods: {
    collectRuleGroup: function () {
      let get = new Get;
      get.get(this.id).then((response) => this.parseRuleGroup(response));
    },
    parseRuleGroup: function (response) {
      this.title = response.data.data.attributes.title;
    },
    resetErrors: function () {
      this.submissionErrors =
        {
          title: '',
        };
      this.hasSubmissionErrors = {
        title: false,
      };
    },
    submitRuleGroup: function () {
      this.submitting = true;
      this.errorMessage = '';

      // reset errors:
      this.resetErrors();

      // build account array
      const submission = this.buildRuleGroup();

      (new Put())
        .post(this.id, submission)
        .catch(this.processErrors)
        .then(this.processSuccess);
    },
    buildRuleGroup: function () {
      return {
        title: this.title,
      };
    },
    dismissBanner: function () {
      this.errorMessage = '';
    },
    processSuccess: function (response) {
      this.store.refreshCacheKey();
      if (!response) {
        return;
      }
      this.submitting = false;
      let message = {
        level: 'success',
        text: 'Rule group is is updated',
        show: true,
        action: {
          show: true,
          text: 'Go to rule group', // todo
          link: {name: 'rule.index'}
        }
      };
      // store flash
      this.$q.localStorage.set('flash', message);
      if (this.doReturnHere) {
        window.dispatchEvent(new CustomEvent('flash', {
          detail: {
            flash: this.$q.localStorage.getItem('flash')
          }
        }));
      }
      if (!this.doReturnHere) {
        // return to previous page.
        this.$router.go(-1);
      }

    },
    processErrors: function (error) {
      if (error.response) {
        let errors = error.response.data; // => the response payload
        this.errorMessage = errors.message;
        console.log(errors);
        for (let i in errors.errors) {
          if (errors.errors.hasOwnProperty(i)) {
            this.submissionErrors[i] = errors.errors[i][0];
            this.hasSubmissionErrors[i] = true;
          }
        }
      }
      this.submitting = false;
    },
  }
}
</script>

<style scoped>

</style>
