package vn.cooky.place_plugin

import android.app.Activity
import android.content.Context
import android.text.style.CharacterStyle
import androidx.annotation.NonNull
import com.google.android.gms.common.api.ApiException
import com.google.android.libraries.places.api.Places
import com.google.android.libraries.places.api.model.AddressComponent
import com.google.android.libraries.places.api.model.AutocompleteSessionToken
import com.google.android.libraries.places.api.model.Place
import com.google.android.libraries.places.api.model.TypeFilter
import com.google.android.libraries.places.api.net.*
import com.google.gson.Gson
import com.google.gson.JsonObject

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject

/** PlacePlugin */
class PlacePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var channel: MethodChannel
    private lateinit var client: PlacesClient
    private lateinit var token: AutocompleteSessionToken
    private lateinit var request: FindAutocompletePredictionsRequest

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "place_plugin")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "search") {
            if (call.hasArgument("keyword")) {
                val keyword = call.argument<String>("keyword") as String
                request = FindAutocompletePredictionsRequest.builder().setCountries("VN")
                    .setTypeFilter(TypeFilter.ADDRESS)
                    .setSessionToken(token)
                    .setQuery(keyword)
                    .build()
                client.findAutocompletePredictions(request)
                    .addOnSuccessListener { response: FindAutocompletePredictionsResponse ->
                        val listResult: MutableList<Map<String, Any>> = mutableListOf()
                        for (prediction in response.autocompletePredictions) {
                            val name = prediction.getPrimaryText(null).toString()
                            val address = prediction.getSecondaryText(null).toString()
                            val placeId = prediction.placeId
                            val formattedAddress = prediction.getFullText(null).toString()

                            val map: Map<String, Any> = mapOf(
                                "name" to name,
                                "address" to address,
                                "placeId" to placeId,
                                "formattedAddress" to formattedAddress
                            )
                            listResult.add(map)
                        }
                        result.success(listResult)
                    }.addOnFailureListener { exception: Exception? ->
                    result.error("null", "find failed", null)
                }
            } else {
                result.error("null", "no keyword", null)
            }

        } else if (call.method == "initialize") {
            if (call.hasArgument("apiKey")) {
                val key = call.argument<String>("apiKey") as String
                Places.initialize(context, key)
                client = Places.createClient(context)
                token = AutocompleteSessionToken.newInstance()
            } else {
                result.error("null", "miss key", null)
            }

        } else if (call.method == "getPlace") {
            if (call.hasArgument("placeId")) {
                val placeId = call.argument<String>("placeId") as String
                val placeFields = listOf(
                    Place.Field.ID,
                    Place.Field.NAME,
                    Place.Field.ADDRESS_COMPONENTS,
                    Place.Field.ADDRESS,
                    Place.Field.LAT_LNG
                )

                val request = FetchPlaceRequest.newInstance(placeId, placeFields)
                client.fetchPlace(request).addOnSuccessListener { response: FetchPlaceResponse ->
                    val place = response.place
                    var city = ""
                    var district = ""

                    if (place.addressComponents != null){
                        val components: List<AddressComponent> = place.addressComponents!!.asList();
                        if(components.isNotEmpty()){
                            for (component in components){
                                val types = component.types
                                if (types.isNotEmpty()){
                                    for (type in types){
                                        if (type == "administrative_area_level_1"){
                                            city = component.name
                                            continue
                                        }
                                        if(type == "administrative_area_level_2"){
                                            district = component.name
                                            continue
                                        }
                                    }
                                }
                            }
                        }
                    }

                    val map: Map<String, Any> = mapOf(
                        "formattedAddress" to place.address!!,
                        "latitude" to place.latLng?.latitude.toString(),
                        "longitude" to place.latLng?.longitude.toString(),
                        "city" to city,
                        "district" to district
                    )
                    result.success(map)

                }.addOnFailureListener { exception: Exception ->
                    if (exception is ApiException) {
                        result.error("null", "Place not found: ${exception.message}", null)
                    }else{
                        result.error("null", "Error: ${exception.message}", null)
                    }
                }
            } else {
                result.error("null", "miss placeid", null)
            }

        } else {
            result.notImplemented()
        }


    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    override fun onDetachedFromActivity() {
        channel.setMethodCallHandler(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {
        channel.setMethodCallHandler(null)
    }
}
