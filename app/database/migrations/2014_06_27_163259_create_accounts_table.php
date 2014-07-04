<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateAccountsTable extends Migration {

	/**
	 * Run the migrations.
	 *
	 * @return void
	 */
	public function up()
	{
		Schema::create('accounts', function(Blueprint $table)
		{
			$table->increments('id');
			$table->timestamps();
            $table->integer('user_id')->unsigned();
            $table->integer('account_type_id')->unsigned();
            $table->string('name',100);
            $table->boolean('active');

            // connect accounts to users
            $table->foreign('user_id')
                ->references('id')->on('users')
                ->onDelete('cascade');

            // connect accounts to account_types
            $table->foreign('account_type_id')
                ->references('id')->on('account_types')
                ->onDelete('cascade');
		});
	}

	/**
	 * Reverse the migrations.
	 *
	 * @return void
	 */
	public function down()
	{
		Schema::drop('accounts');
	}

}