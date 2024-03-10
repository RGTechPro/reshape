
import 'package:reshape/environment/environment.dart';
import 'package:reshape/modules/core/data/network/network.dart';

part 'network_defaults.dart';

abstract class AppNetworkingBox<C, O>  {
  
  static final AppNetworkingBoxImpl instance = AppNetworkingBoxImpl();

  static final AppNetworkingDefaults defaults = AppNetworkingDefaults._();

  Future<C?> secureClient({
    O? options,
    bool loggingEnabled = true,
  });

  Future<C> unsecureClient({
    O? options,
    bool loggingEnabled = true,
  });
}
